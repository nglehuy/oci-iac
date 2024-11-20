variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

/* -------------------------------------------------- ELASTICSEARCH ------------------------------------------------- */

variable "elasticsearch_password" {
  description = "Elasticsearch password"
}

variable "elasticsearch_request_cpu" {
  description = "Elasticsearch request CPU"
  default     = "200m"
}

variable "elasticsearch_request_memory" {
  description = "Elasticsearch request memory"
  default     = "2Gi"
}

variable "elasticsearch_limit_cpu" {
  description = "Elasticsearch limit CPU"
  default     = "500m"
}

variable "elasticsearch_limit_memory" {
  description = "Elasticsearch limit memory"
  default     = "3Gi"
}

/* ----------------------------------------------------- KIBANA ----------------------------------------------------- */

variable "kibana_ingress_host" {
  description = "Ingress host for kibana"
  default     = ""
}

variable "kibana_request_cpu" {
  description = "Kibana request CPU"
  default     = "100m"
}

variable "kibana_request_memory" {
  description = "Kibana request memory"
  default     = "1Gi"
}

variable "kibana_limit_cpu" {
  description = "Kibana limit CPU"
  default     = "500m"
}

variable "kibana_limit_memory" {
  description = "Kibana limit memory"
  default     = "2Gi"
}


/* ---------------------------------------------------- FILEBEAT ---------------------------------------------------- */

variable "filebeat_request_cpu" {
  description = "Filebeat request CPU"
  default     = "100m"
}

variable "filebeat_request_memory" {
  description = "Filebeat request memory"
  default     = "200Mi"
}

variable "filebeat_limit_cpu" {
  description = "Filebeat limit CPU"
  default     = "500m"
}

variable "filebeat_limit_memory" {
  description = "Filebeat limit memory"
  default     = "256Mi"
}
