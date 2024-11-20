locals {
  namespace = "elastic-system"
  version   = "8.16.0"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "elastic" {
  name       = "elastic-operator"
  repository = "https://helm.elastic.co"
  chart      = "eck-operator"
  version    = "2.14.0"
  namespace  = local.namespace
  depends_on = [
    kubernetes_namespace.this,
  ]
  values = [
    "${file("./values.tftpl")}"
  ]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [helm_release.elastic]
  create_duration = "30s"
}

resource "kubectl_manifest" "elasticsearch" {
  yaml_body = <<YAML
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elasticsearch
  namespace: ${local.namespace}
spec:
  version: ${local.version}
  nodeSets:
    - name: default
      count: 2
      podTemplate:
        spec:
          containers:
            - name: elasticsearch
              resources:
                requests:
                  cpu: ${var.elasticsearch_request_cpu}
                  memory: ${var.elasticsearch_request_memory}
                limits:
                  cpu: ${var.elasticsearch_limit_cpu}
                  memory: ${var.elasticsearch_limit_memory}
              env:
                - name: ES_JAVA_OPTS
                  value: "-Xms1g -Xmx1g"
      config:
        node.store.allow_mmap: false
        node.roles: ["master", "data", "ingest"]
        bootstrap.memory_lock: true
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 20Gi
              limits:
                storage: 20Gi
            storageClassName: local-ocfs2-path
YAML

  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [helm_release.elastic, time_sleep.wait_30_seconds]
}

resource "kubectl_manifest" "kibana" {
  yaml_body = <<YAML
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kibana
  namespace: ${local.namespace}
spec:
  version: ${local.version}
  count: 1
  elasticsearchRef:
    name: elasticsearch
  config:
    server.publicBaseUrl: ${var.kibana_ingress_host != "" ? "https://${var.kibana_ingress_host}" : ""}
  podTemplate:
    spec:
      containers:
        - name: kibana
          env:
            - name: NODE_OPTIONS
              value: "--max-old-space-size=2048"
          resources:
            requests:
              cpu: ${var.kibana_request_cpu}
              memory: ${var.kibana_request_memory}
            limits:
              cpu: ${var.kibana_limit_cpu}
              memory: ${var.kibana_limit_memory}
  http:
    tls:
      selfSignedCertificate:
        disabled: true   
YAML

  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [helm_release.elastic, kubectl_manifest.elasticsearch]
}

resource "kubernetes_ingress_v1" "kibana" {
  count = var.kibana_ingress_host != "" ? 1 : 0
  metadata {
    name      = "kibana"
    namespace = local.namespace
    annotations = {
      "cert-manager.io/cluster-issuer" = "letsencrypt-issuer"
    }
  }
  spec {
    ingress_class_name = "nginx"
    default_backend {
      service {
        name = "kibana-kb-http"
        port {
          number = 5601
        }
      }
    }
    rule {
      host = var.kibana_ingress_host
      http {
        path {
          backend {
            service {
              name = "kibana-kb-http"
              port {
                number = 5601
              }
            }
          }
          path = "/"
        }
      }
    }
    tls {
      hosts       = [var.kibana_ingress_host]
      secret_name = "kibana-kb-tls"
    }
  }
  depends_on = [kubectl_manifest.kibana]
}

resource "kubernetes_cluster_role" "filebeat" {
  metadata {
    name = "filebeat"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account" "filebeat" {
  metadata {
    name      = "filebeat"
    namespace = local.namespace
  }
}

resource "kubernetes_cluster_role_binding" "filebeat" {
  metadata {
    name = "filebeat"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "filebeat"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "filebeat"
    namespace = local.namespace
  }
  depends_on = [kubernetes_cluster_role.filebeat]
}

resource "kubectl_manifest" "filebeat" {
  yaml_body = <<YAML
apiVersion: beat.k8s.elastic.co/v1beta1
kind: Beat
metadata:
  name: filebeat
  namespace: ${local.namespace}
spec:
  type: filebeat
  version: ${local.version}
  elasticsearchRef:
    name: elasticsearch
  kibanaRef:
    name: kibana
  config:
    filebeat.autodiscover:
      providers:
      - type: kubernetes
        node: $${NODE_NAME}
        hints:
          enabled: true
          default_config:
            type: container
            paths:
            - /var/log/containers/*.log
            - /var/lib/docker/containers/*/*.log
    processors:
    - add_cloud_metadata: {}
    - add_host_metadata: {}
    - add_kubernetes_metadata: {}
  daemonSet:
    podTemplate:
      spec:
        serviceAccountName: ${kubernetes_service_account.filebeat.metadata.0.name}
        automountServiceAccountToken: true
        terminationGracePeriodSeconds: 30
        dnsPolicy: ClusterFirstWithHostNet
        hostNetwork: true # Allows to provide richer host metadata
        containers:
        - name: filebeat
          securityContext:
            runAsUser: 0
          resources:
            requests:
              cpu: ${var.filebeat_request_cpu}
              memory: ${var.filebeat_request_memory}
            limits:
              cpu: ${var.filebeat_limit_cpu}
              memory: ${var.filebeat_limit_memory}
          volumeMounts:
          - name: varlogcontainers
            mountPath: /var/log/containers
          - name: varlogpods
            mountPath: /var/log/pods
          - name: varlibdockercontainers
            mountPath: /var/lib/docker/containers
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
        volumes:
        - name: varlogcontainers
          hostPath:
            path: /var/log/containers
        - name: varlogpods
          hostPath:
            path: /var/log/pods
        - name: varlibdockercontainers
          hostPath:
            path: /var/lib/docker/containers
YAML

  provisioner "local-exec" {
    command = "sleep 60"
  }
  depends_on = [
    helm_release.elastic,
    kubectl_manifest.elasticsearch,
    kubectl_manifest.kibana,
    kubernetes_cluster_role.filebeat,
    kubernetes_service_account.filebeat,
    kubernetes_cluster_role_binding.filebeat
  ]
}
