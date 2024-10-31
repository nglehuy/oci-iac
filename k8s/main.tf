data "local_file" "inventory_script" {
  filename = "./ansible/scripts/inventory.py"
}

resource "null_resource" "inventory" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
  }

  provisioner "local-exec" {
    command     = <<-EOT
      python3 scripts/inventory.py \
        --kube-control-planes '${self.triggers.kube_control_plane_instances}' \
        --kube-nodes '${self.triggers.kube_node_instances}' \
        --output-file hosts.yml
    EOT
    working_dir = "ansible"
  }
}

resource "null_resource" "cluster" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
    inventory_script             = data.local_file.inventory_script.content
    ssh_private_key              = var.ssh_private_key
    ssh_user                     = var.ssh_user
  }

  depends_on = [null_resource.inventory]

  # list tags: https://github.com/kubernetes-sigs/kubespray/blob/master/docs/ansible/ansible.md
  provisioner "local-exec" {
    when        = create
    command     = <<-EOT
      FILE=cluster.yml
      if ! [ -f ../.cluster.lock ]; then
        echo "Creating cluster..."
      else
        echo "Cluster already created, upgrading..."
        FILE=upgrade-cluster.yml
      fi
      ansible-playbook -i ../hosts.yml $FILE \
        -v --private-key=${var.ssh_private_key} --become -u ${var.ssh_user}
      touch ../.cluster.lock
    EOT
    working_dir = "ansible/kubespray"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
      if [ "$FORCE" == "true" ]; then # only destroy if forced
        ansible-playbook -i ../hosts.yml reset.yml \
          -e skip_confirmation=yes -e reset_confirmation=yes \
          -v --private-key=${self.triggers.ssh_private_key} --become -u ${self.triggers.ssh_user}
        rm -f ../.cluster.lock
      fi
    EOT
    working_dir = "ansible/kubespray"
  }
}
