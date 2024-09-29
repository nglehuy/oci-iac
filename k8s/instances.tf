data "oci_core_instance" "nlhuycs" {
  for_each    = var.ocis.nlhuycs.instances
  instance_id = each.value.id
}
