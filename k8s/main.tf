# resource "local_file" "ansible_inventory_nodes" {
#   for_each = tomap(data.oci_core_instance.nlhuycs)
#   filename = "./ansible/inventory.ini"
#   content  = <<-EOF
# [all]
# master ansible_host=${each.value.public_ip} ansible_become=true
# worker-1 ansible_host=${each.value.public_ip} ansible_become=true

# [kube_control_plane]
# master

# [etcd]
# master

# [kube_node]
# master
# worker-1

# [k8s_cluster:children]
# kube_control_plane
# kube_node
#   EOF

#   provisioner "local-exec" {
#     command     = "ansible-playbook -i inventory.ini playbook.yml"
#     working_dir = "ansible"
#     environment = {
#       ANSIBLE_HOST_KEY_CHECKING = "false"
#     }
#   }
# }

data "local_file" "inventory_script" {
  filename = "./ansible/scripts/inventory.py"
}

resource "null_resource" "cluster" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
    inventory_script             = data.local_file.inventory_script.content
  }

  provisioner "local-exec" {
    command     = <<-EOT
      python3 ./scripts/inventory.py \
        --kube-control-planes '${jsonencode(data.oci_core_instance.kube_control_planes)}' \
        --kube-nodes '${jsonencode(data.oci_core_instance.kube_nodes)}' \
        --output-file hosts.yml
    EOT
    working_dir = "ansible"
  }

  provisioner "local-exec" {
    command     = <<-EOT
      ansible-playbook -i ../hosts.yml cluster.yml -b -v --private-key=${var.ssh_private_key}
    EOT
    working_dir = "ansible/kubespray"
    environment = {
      # ANSIBLE_HOST_KEY_CHECKING = "false"
    }
  }
}
