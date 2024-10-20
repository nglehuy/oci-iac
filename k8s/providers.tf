provider "oci" {
  alias            = "oci0" # value must be known before variable is defined
  user_ocid        = var.ocis[0].user
  fingerprint      = var.ocis[0].fingerprint
  tenancy_ocid     = var.ocis[0].tenancy
  region           = var.ocis[0].region
  private_key_path = var.ocis[0].api_key_path
}

# add more oci provider block if needed
