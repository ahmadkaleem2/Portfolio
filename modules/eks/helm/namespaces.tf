resource "kubernetes_namespace" "karpenter_ns" {
  metadata {
    name = "karpenter"
  }
  
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
  
}

resource "kubernetes_namespace" "external-dns" {
  metadata {
    name = "external-dns"
  }
  
}

resource "kubernetes_namespace" "aws-load-balancer-controller" {
  metadata {
    annotations = {
      name = "aws-load-balancer-controller"
    }

    labels = {
      name = "aws-load-balancer-controller"
    }

    name = "aws-load-balancer-controller"
  }
}

