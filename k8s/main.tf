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
      python3 ./scripts/inventory.py \
        --kube-control-planes '${self.triggers.kube_control_plane_instances}' \
        --kube-nodes '${self.triggers.kube_node_instances}' \
        --output-file hosts.yml
    EOT
    working_dir = "ansible"
  }

  provisioner "local-exec" {
    when        = create
    command     = <<-EOT
      ansible-playbook -i ../hosts.yml cluster.yml \
        -v --private-key=${var.ssh_private_key} -b -u ${var.ssh_user}
    EOT
    working_dir = "ansible/kubespray"
  }

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
      ansible-playbook -i ../hosts.yml reset.yml \
        -v --private-key=$ssh_private_key -b -u $ssh_user
    EOT
    working_dir = "ansible/kubespray"
    environment = {
      ssh_private_key = self.triggers.ssh_private_key
      ssh_user        = self.triggers.ssh_user
    }
  }
}
