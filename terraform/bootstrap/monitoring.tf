resource "helm_release" "kube_prometheus_stack" {
  name      = "kube-prometheus-stack"
  namespace = kubernetes_namespace.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "84.5.0"

  values = [
    yamlencode({
      grafana = {
        enabled = true

        adminPassword = "admin"

        service = {
          type     = "NodePort"
          nodePort = 31030

        }
      }

      prometheus = {
        prometheusSpec = {
          retention = "7d"

          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "local-path"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "5Gi"
                  }
                }
              }
            }
          }
        }
      }

      alertmanager = {
        enabled = true

        alertmanagerSpec = {
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "local-path"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = "2Gi"
                  }
                }
              }
            }
          }
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}
