data "local_file" "inventory_script" {
  filename = "./ansible/scripts/inventory.py"
}

resource "local_file" "group_vars" {
  content  = <<-EOT
    helm_enabled: true

    registry_enabled: true
    registry_namespace: "kube-system"
    registry_disk_size: "10Gi"

    metrics_server_enabled: true
    metrics_server_kubelet_insecure_tls: true

    ingress_nginx_enabled: true

    cert_manager_enabled: true

    krew_enabled: true

    ntp_enabled: true
    ntp_timezone: Asia/Ho_Chi_Minh
    ntp_manage_config: true
    ntp_tinker_panic: true
    ntp_force_sync_immediately: true

    kube_network_plugin: "cilium" # to fit with metallb

    metallb_enabled: true
    metallb_namespace: "metallb-system"
  EOT
  filename = "./ansible/inventory/group_vars/all.yml"
}

resource "null_resource" "hosts" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
  }

  provisioner "local-exec" {
    command     = <<-EOT
      python3 scripts/inventory.py \
        --kube-control-planes '${self.triggers.kube_control_plane_instances}' \
        --kube-nodes '${self.triggers.kube_node_instances}' \
        --output-file ./inventory/hosts.yml
    EOT
    working_dir = "ansible"
  }
}

resource "null_resource" "cluster" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
    ssh_private_key              = var.ssh_private_key
    ssh_user                     = var.ssh_user
    hosts_ref                    = null_resource.hosts.id
    group_vars_content           = local_file.group_vars.content
  }

  depends_on = [
    local_file.group_vars,
    null_resource.hosts
  ]

  # list tags: https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible/ansible.md
  provisioner "local-exec" {
    when        = create
    command     = <<-EOT
      ansible-playbook -i ../inventory cluster.yml \
        -v --private-key=${var.ssh_private_key} --become -u ${var.ssh_user}
    EOT
    working_dir = "ansible/kubespray"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
      # only destroy if forced
      if [ "$FORCE" == "true" ]; then
        ansible-playbook -i ../inventory reset.yml \
          -e skip_confirmation=yes -e reset_confirmation=yes \
          -v --private-key=${self.triggers.ssh_private_key} --become -u ${self.triggers.ssh_user}
      fi
    EOT
    working_dir = "ansible/kubespray"
  }
}
