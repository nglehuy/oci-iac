variable "kube_config_path" {
  description = "Path to the kubeconfig file"
  default     = "~/.kube/config"
}

variable "admin_password" {
  description = "Admin password"
}

/* -------------------------------------------------- ELASTICSEARCH ------------------------------------------------- */

variable "elasticsearch_username" {
  description = "Elasticsearch username"
}

variable "elasticsearch_password" {
  description = "Elasticsearch password"
}

variable "elasticsearch_request_cpu" {
  description = "Elasticsearch request CPU"
  default     = "250m"
}

variable "elasticsearch_request_memory" {
  description = "Elasticsearch request memory"
  default     = "1Gi"
}

variable "elasticsearch_limit_cpu" {
  description = "Elasticsearch limit CPU"
  default     = "500m"
}

variable "elasticsearch_limit_memory" {
  description = "Elasticsearch limit memory"
  default     = "2Gi"
}

/* ----------------------------------------------------- KIBANA ----------------------------------------------------- */

variable "kibana_ingress_host" {
  description = "Ingress host for kibana"
  default     = ""
}

variable "kibana_username" {
  description = "Kibana username"
}

variable "kibana_password" {
  description = "Kibana password"
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

/* ---------------------------------------------------- LOGSTASH ---------------------------------------------------- */

variable "logstash_request_cpu" {
  description = "Logstash request CPU"
  default     = "100m"
}

variable "logstash_request_memory" {
  description = "Logstash request memory"
  default     = "1Gi"
}

variable "logstash_limit_cpu" {
  description = "Logstash limit CPU"
  default     = "500m"
}

variable "logstash_limit_memory" {
  description = "Logstash limit memory"
  default     = "1536Mi"
}


/* ---------------------------------------------------- FILEBEAT ---------------------------------------------------- */

variable "filebeat_request_cpu" {
  description = "Filebeat request CPU"
  default     = "100m"
}

variable "filebeat_request_memory" {
  description = "Filebeat request memory"
  default     = "100Mi"
}

variable "filebeat_limit_cpu" {
  description = "Filebeat limit CPU"
  default     = "500m"
}

variable "filebeat_limit_memory" {
  description = "Filebeat limit memory"
  default     = "200Mi"
}
