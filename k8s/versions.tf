terraform {
  required_version = ">= 0.13.1"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.11.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }
  }
}
