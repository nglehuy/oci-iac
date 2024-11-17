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
    - name: master
      count: 1
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
        node.roles: ["master"]
        bootstrap.memory_lock: true
      volumeClaimTemplates:
        - metadata:
            name: elasticsearch-data
          spec:
            accessModes:
              - ReadWriteOnce
            resources:
              requests:
                storage: 10Gi
              limits:
                storage: 10Gi
            storageClassName: local-ocfs2-path
    - name: data
      count: 1
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
                  value: "-Xms512m -Xmx512m"
      config:
        node.store.allow_mmap: false
        node.roles: ["data"]
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
          path_type = "ImplementationSpecific"
          path      = "/?(.*)"
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

# resource "kubectl_manifest" "filebeat" {
#   yaml_body = <<YAML
# apiVersion: beat.k8s.elastic.co/v1beta1
# kind: Beat
# metadata:
#   name: filebeat
# spec:
#   type: filebeat
#   version: 8.16.0
#   elasticsearchRef:
#     name: elasticsearch
#   config:
#     filebeat.inputs:
#     - type: container
#       paths:
#       - /var/log/containers/*.log
#   daemonSet:
#     podTemplate:
#       spec:
#         dnsPolicy: ClusterFirstWithHostNet
#         hostNetwork: true
#         securityContext:
#           runAsUser: 0
#         containers:
#         - name: filebeat
#           volumeMounts:
#           - name: varlogcontainers
#             mountPath: /var/log/containers
#           - name: varlogpods
#             mountPath: /var/log/pods
#           - name: varlibdockercontainers
#             mountPath: /var/lib/docker/containers
#         volumes:
#         - name: varlogcontainers
#           hostPath:
#             path: /var/log/containers
#         - name: varlogpods
#           hostPath:
#             path: /var/log/pods
#         - name: varlibdockercontainers
#           hostPath:
#             path: /var/lib/docker/containers
# YAML

#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
#   depends_on = [helm_release.elastic, kubectl_manifest.elasticsearch]
# }


# resource "kubectl_manifest" "logstash" {
#   yaml_body = <<YAML
# apiVersion: logstash.k8s.elastic.co/v1alpha1
# kind: Logstash
# metadata:
#   name: quickstart
# spec:
#   count: 1
#   elasticsearchRefs:
#     - name: elasticsearch
#   version: 8.16.0
#   pipelines:
#     - pipeline.id: main
#       config.string: |
#         input {
#           beats {
#             port => 5044
#           }
#         }
#         output {
#           elasticsearch {
#             hosts => [ "${QS_ES_HOSTS}" ]
#             user => "${QS_ES_USER}"
#             password => "${QS_ES_PASSWORD}"
#             ssl_certificate_authorities => "${QS_ES_SSL_CERTIFICATE_AUTHORITY}"
#           }
#         }
#   services:
#     - name: beats
#       service:
#         spec:
#           type: NodePort
#           ports:
#             - port: 5044
#               name: "filebeat"
#               protocol: TCP
#               targetPort: 5044
# YAML

#   provisioner "local-exec" {
#     command = "sleep 60"
#   }
#   depends_on = [helm_release.elastic, kubectl_manifest.elasticsearch]
# }
