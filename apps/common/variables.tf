variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

/* ------------------------------------------------------ EMAIL ----------------------------------------------------- */

variable "email" {
  description = "Email address"
  type        = string
}

/* --------------------------------------------------- DOCKER HUB --------------------------------------------------- */

variable "dockerhub_namespace" {
  description = "Namespace for pods to pull images from Docker Hub"
  type        = string
}

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
}

variable "dockerhub_password" {
  description = "Docker Hub password"
  type        = string
}

variable "dockerhub_email" {
  description = "Docker Hub email"
  type        = string
}
