resource "kubernetes_persistent_volume" "prometheus" {
  metadata {
    name = "prometheus"
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
  lifecycle {
    prevent_destroy = true
  }
}
