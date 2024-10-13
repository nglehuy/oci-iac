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

resource "null_resource" "inventory" {
  triggers = {
    kube_control_plane_instances = jsonencode(data.oci_core_instance.kube_control_planes)
    kube_node_instances          = jsonencode(data.oci_core_instance.kube_nodes)
    kube_etcd_instances          = jsonencode(data.oci_core_instance.kube_etcds)
  }

  provisioner "local-exec" {
    command     = <<-EOT
      python3 ./scripts/inventory.py \
        --kube-control-planes '${jsonencode(data.oci_core_instance.kube_control_planes)}' \
        --kube-nodes '${jsonencode(data.oci_core_instance.kube_nodes)}' \
        --kube-etcds '${jsonencode(data.oci_core_instance.kube_etcds)}' \
        --output-file inventory.ini
    EOT
    working_dir = "ansible"
  }

  provisioner "local-exec" {
    command     = "ansible-playbook -i inventory.ini playbook.yml"
    working_dir = "ansible"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "false"
    }
  }
}
