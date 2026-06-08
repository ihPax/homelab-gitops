resource "kubernetes_namespace" "homelab" {
  metadata {
    name = "homelab"

    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "homelab.lorenzo.io/purpose"   = "apps"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "homelab.lorenzo.io/purpose"   = "observability"
    }
  }
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"

    labels = {
      "app.kubernetes.io/managed-by" = "opentofu"
      "homelab.lorenzo.io/purpose"   = "networking"
    }
  }
}
