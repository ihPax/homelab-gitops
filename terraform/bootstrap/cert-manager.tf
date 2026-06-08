resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"

    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "homelab.lorenzo.io/purpose"   = "certificate-management"
    }
  }
}

resource "helm_release" "cert_manager" {
  name      = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.16.2"

  set {
    name  = "crds.enabled"
    value = "true"
  }
}
