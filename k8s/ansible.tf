resource "local_file" "ansible_inventory_nodes" {
  for_each = tomap(data.oci_core_instance.nlhuycs)
  filename = "./ansible/inventory-${each.value.hostname_label}.ini"
  content  = <<-EOF
  k8s-cp-${each.value.hostname_label} ansible_host=${each.value.public_ip} ansible_become=true
  k8s-worker-${each.value.hostname_label} ansible_host=${each.value.public_ip} ansible_become=true

  [kube_control_plane]
  k8s-cp-${each.value.hostname_label}

  [etcd]
  k8s-cp-${each.value.hostname_label}

  [kube_node]
  k8s-worker-${each.value.hostname_label}
  
  [k8s_cluster:children]
  kube_node
  kube_control_plane
  EOF

  provisioner "local-exec" {
    command     = "ansible-playbook -i inventory.ini playbook.yml"
    working_dir = "ansible"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "false"
    }
  }
}
