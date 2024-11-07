variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

/* ------------------------------------------------------ EMAIL ----------------------------------------------------- */

variable "email" {
  description = "Email address"
  type        = string
}

