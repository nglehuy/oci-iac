data "local_file" "inventory_script" {
  filename = "./ansible/scripts/inventory.py"
}

resource "null_resource" "cluster" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
    inventory_script             = data.local_file.inventory_script.content
    ssh_private_key              = var.ssh_private_key
    ssh_user                     = var.ssh_user
  }

  provisioner "local-exec" {
    when        = create
    command     = <<-EOT
      python3 ../scripts/inventory.py \
        --kube-control-planes '${self.triggers.kube_control_plane_instances}' \
        --kube-nodes '${self.triggers.kube_node_instances}' \
        --output-file ../hosts.yml
      ansible-playbook -i ../hosts.yml cluster.yml \
        -v --private-key=${var.ssh_private_key} --become -u ${var.ssh_user}
    EOT
    working_dir = "ansible/kubespray"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
      python3 ../scripts/inventory.py \
        --kube-control-planes '${self.triggers.kube_control_plane_instances}' \
        --kube-nodes '${self.triggers.kube_node_instances}' \
        --output-file ../hosts.yml
      ansible-playbook -i ../hosts.yml reset.yml \
        -e skip_confirmation=yes -e reset_confirmation=yes \
        -v --private-key=${self.triggers.ssh_private_key} --become -u ${self.triggers.ssh_user}
    EOT
    working_dir = "ansible/kubespray"
  }
}
