terraform {
  required_version = ">= 1.9.0"
  required_providers {
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "~>0.9"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }
  }
}
