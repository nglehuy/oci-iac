variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "ingress_host" {
  description = "Ingress host for prometheus"
  default     = ""
}

variable "admin_password" {
  description = "Admin password for prometheus"
}
