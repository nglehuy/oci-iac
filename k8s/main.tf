data "local_file" "group_vars_script" {
  filename = "./ansible/scripts/group_vars.py"
}

resource "null_resource" "group_vars" {
  triggers = {
    script  = data.local_file.group_vars_script.content
    command = <<-EOT
      python3 scripts/group_vars.py \
        --nlbs '${jsonencode(data.oci_network_load_balancer_network_load_balancer.kube_network_lbs)}' \
        --registry-htpasswd "${var.registry_htpasswd}" \
        --output-file ./inventory/group_vars/all.yml
    EOT
  }

  provisioner "local-exec" {
    command     = self.triggers.command
    working_dir = "ansible"
  }
}

data "local_file" "inventory_script" {
  filename = "./ansible/scripts/inventory.py"
}

resource "null_resource" "hosts" {
  triggers = {
    script  = data.local_file.inventory_script.content
    command = <<-EOT
      python3 scripts/inventory.py \
        --kube-control-planes '${jsonencode(data.oci_core_instance.kube_control_planes)}' \
        --kube-nodes '${jsonencode(data.oci_core_instance.kube_nodes)}' \
        --output-file ./inventory/hosts.yml
    EOT
  }

  provisioner "local-exec" {
    command     = self.triggers.command
    working_dir = "ansible"
  }
}

resource "null_resource" "cluster" {
  triggers = {
    ssh_private_key = var.ssh_private_key
    ssh_user        = var.ssh_user
    hosts_ref       = null_resource.hosts.id
    group_vars_ref  = null_resource.group_vars.id
    command         = <<-EOT
      ansible-playbook -i ../inventory cluster.yml \
        -v --private-key=${var.ssh_private_key} --become -u ${var.ssh_user}
    EOT
  }

  depends_on = [
    null_resource.group_vars,
    null_resource.hosts
  ]

  provisioner "local-exec" {
    when        = create
    command     = self.triggers.command
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
