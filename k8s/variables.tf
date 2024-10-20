/* ------------------------------------------------------- OCI ------------------------------------------------------ */

variable "ocis" {
  description = "OCI configurations"
  type = list(object({
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
    }))
  }))
}


/* ------------------------------------------------------- SSH ------------------------------------------------------ */

variable "ssh_private_key" {
  description = "Path to the SSH private key"
  type        = string
  default     = "~/.ssh/id_rsa"
}
