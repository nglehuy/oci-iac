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

resource "kubernetes_persistent_volume" "prometheus" {
  metadata {
    name = "prometheus"
  }
  spec {
    capacity = {
      storage = "5Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-ocfs2-storage"
    persistent_volume_reclaim_policy = "Delete"
    persistent_volume_source {
      local {
        path = "/ocfs2" # same as local-storage in kubespray
      }
    }
    node_affinity {
      required {
        node_selector_term {
          match_expressions {
            key      = "node-role.kubernetes.io/control-plane"
            operator = "Exists"
          }
        }
      }
    }
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
      grafana_ingress_host = var.grafana_ingress_host
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
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.volumeName"
    value = kubernetes_persistent_volume.prometheus.metadata.0.name
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = kubernetes_persistent_volume.prometheus.spec.0.capacity.storage
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.limits.storage"
    value = kubernetes_persistent_volume.prometheus.spec.0.capacity.storage
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = kubernetes_persistent_volume.prometheus.spec.0.storage_class_name
  }
}
