data "oci_core_instance" "kube_control_planes" {
  for_each = tomap(flatten([
    for key, tenancy in var.ocis : [
      for instance in tenancy.instances : instance if instance.is_control_plane
    ]
  ]))
  instance_id = each.value.id
}

data "oci_core_instance" "kube_nodes" {
  for_each = tomap(flatten([
    for key, tenancy in var.ocis : [
      for instance in tenancy.instances : instance
    ]
  ]))
  instance_id = each.value.id
}

data "oci_core_instance" "kube_etcds" {
  for_each = tomap(flatten([
    for key, tenancy in var.ocis : [
      for instance in tenancy.instances : instance if instance.is_etcd
    ]
  ]))
  instance_id = each.value.id
}
