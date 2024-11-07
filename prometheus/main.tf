locals {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  version    = "25.29.0"
  namespace  = "prometheus"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "this" {
  name       = local.name
  repository = local.repository
  chart      = local.chart
  version    = local.version
  namespace  = local.namespace
  depends_on = [
    kubernetes_namespace.this,
    kubernetes_persistent_volume.server,
    kubernetes_persistent_volume_claim.server,
  ]
  # Ref: https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml
  values = [
    "${templatefile("values.tftpl", {
      ingress_host  = var.ingress_host
      storage_class = "local-storage"
      volume_name   = kubernetes_persistent_volume.server.metadata.0.name
    })}"
  ]
  set {
    name  = "server.ingress.enabled"
    value = var.ingress_host != "" ? true : false
  }
}
