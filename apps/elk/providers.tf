provider "elasticstack" {
  elasticsearch {
    username  = var.elasticsearch_username
    password  = var.elasticsearch_password
    endpoints = ["http://localhost:9200"]
  }
  kibana {
    username  = var.kibana_username
    password  = var.kibana_password
    endpoints = ["http://localhost:5601"]
  }
}

provider "kubernetes" {
  config_path = var.kube_config_path
}
