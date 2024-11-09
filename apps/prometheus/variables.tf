variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "grafana_ingress_host" {
  description = "Grafana ingress host for prometheus"
  default     = ""
}

variable "admin_password" {
  description = "Admin password for prometheus"
}
