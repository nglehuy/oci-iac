data "oci_core_instance" "kube_control_planes" {
  for_each = toset(flatten([
    for tenancy in var.ocis : [
      for instance in tenancy.instances : instance.id if instance.is_control_plane
    ]
  ]))
  instance_id = each.value
}

data "oci_core_instance" "kube_nodes" {
  for_each = toset(flatten([
    for tenancy in var.ocis : [
      for instance in tenancy.instances : instance.id
    ]
  ]))
  instance_id = each.value
}
