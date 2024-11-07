/* ----------------------------------------------------- SERVER ----------------------------------------------------- */

resource "kubernetes_persistent_volume" "server" {
  metadata {
    name = "prometheus-server"
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes                     = ["ReadWriteOnce"]
    storage_class_name               = "local-storage"
    persistent_volume_reclaim_policy = "Delete"
    persistent_volume_source {
      local {
        path = "/mnt/disks" # same as local-storage in kubespray
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

resource "kubernetes_persistent_volume_claim" "server" {
  metadata {
    name      = "prometheus-server"
    namespace = local.namespace
  }
  spec {
    access_modes       = ["ReadWriteOnce"]
    storage_class_name = "local-storage"
    resources {
      requests = {
        storage = "2Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.server.metadata.0.name
  }
}
