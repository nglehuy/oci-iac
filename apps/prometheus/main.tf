locals {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "65.8.1"
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
    kubernetes_persistent_volume.prometheus,
  ]
  # Ref: https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml
  values = [
    "${templatefile("values.tftpl", {
      grafana_ingress_host   = var.grafana_ingress_host
      prometheus_volume_name = kubernetes_persistent_volume.prometheus.metadata.0.name
    })}"
  ]
  set {
    name  = "grafana.ingress.enabled"
    value = var.grafana_ingress_host != "" ? true : false
  }
  set {
    name  = "grafana.adminPassword"
    value = var.admin_password
  }
}
