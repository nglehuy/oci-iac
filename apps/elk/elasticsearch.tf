resource "kubernetes_persistent_volume" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
  spec {
    capacity = {
      storage = "30Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-storage"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      local {
        path = "/mnt/disks"
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
  lifecycle {
    prevent_destroy = true
  }
}

resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "8.5.1"
  namespace  = local.namespace
  depends_on = [
    kubernetes_namespace.this,
    kubernetes_persistent_volume.elasticsearch,
  ]
  values = [
    "${templatefile("./values/elasticsearch.tftpl", {
      volume_name = kubernetes_persistent_volume.elasticsearch.metadata.0.name
    })}"
  ]
  set {
    name  = "secrets.password"
    value = var.elasticsearch_password
  }
  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = kubernetes_persistent_volume.elasticsearch.spec.0.capacity.0.storage
  }
  set {
    name  = "resources.requests.cpu"
    value = var.elasticsearch_request_cpu
  }
  set {
    name  = "resources.requests.memory"
    value = var.elasticsearch_request_memory
  }
  set {
    name  = "resources.limits.cpu"
    value = var.elasticsearch_limit_cpu
  }
  set {
    name  = "resources.limits.memory"
    value = var.elasticsearch_limit_memory
  }
}
