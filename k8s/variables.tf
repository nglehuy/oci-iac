/* ------------------------------------------------------- OCI ------------------------------------------------------ */

variable "ocis" {
  description = "OCI configurations"
  type = map(object({
    name             = string
    user             = string
    fingerprint      = string
    tenancy          = string
    region           = string
    api_key_path     = string
    api_pub_key_path = string
    instances = list(object({
      id               = string
      name             = string
      is_control_plane = bool
      is_etcd          = bool
    }))
  }))
}
