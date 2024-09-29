provider "oci" {
  alias               = var.ocis.nlhuycs.name
  user_ocid           = var.ocis.nlhuycs.user
  fingerprint         = var.ocis.nlhuycs.fingerprint
  tenancy_ocid        = var.ocis.nlhuycs.tenancy
  region              = var.ocis.nlhuycs.region
  private_key_path    = var.ocis.nlhuycs.api_key_path
  ignore_defined_tags = ["Oracle-Tags.CreatedBy", "Oracle-Tags.CreatedOn"]
}
