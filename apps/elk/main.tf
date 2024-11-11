locals {
  namespace = "elastics"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }
}
