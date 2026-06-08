resource "kubernetes_manifest" "selfsigned_cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = "selfsigned-cluster-issuer"

      labels = {
        "app.kubernetes.io/managed-by" = "opentofu"
        "homelab.lorenzo.io/purpose"   = "certificate-management"
      }
    }

    spec = {
      selfSigned = {}
    }
  }

  depends_on = [
    helm_release.cert_manager
  ]
}
