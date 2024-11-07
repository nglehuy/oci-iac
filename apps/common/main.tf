/* -------------------------------------------------- CERT MANAGER -------------------------------------------------- */

resource "kubernetes_manifest" "letsencrypt_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-issuer"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.email
        privateKeySecretRef = {
          name = "letsencrypt-issuer"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                ingressClassName = "nginx"
              }
            }
          }
        ]
      }
    }
  }
}

/* --------------------------------------------------- DOKCER HUB --------------------------------------------------- */

resource "kubernetes_namespace" "dockerhub" {
  metadata {
    name = var.dockerhub_namespace
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "kubernetes_secret" "dockerhub" {
  metadata {
    name      = "dockerhub-creds"
    namespace = kubernetes_namespace.dockerhub.metadata.0.name
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "https://index.docker.io/v1/" = {
          "username" = var.dockerhub_username
          "password" = var.dockerhub_password
          "email"    = var.dockerhub_email
          "auth"     = base64encode("${var.dockerhub_username}:${var.dockerhub_password}")
        }
      }
    })
  }
  depends_on = [
    kubernetes_namespace.dockerhub
  ]
}
