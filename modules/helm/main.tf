resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace = "aws-load-balancer-controller"
  create_namespace = false
  cleanup_on_fail = true
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name = "clusterName"
    value = var.eks_cluster_name
  }
  set {
    name = "region"
    value = var.aws_region
  }
  set {
    name = "vpcId"
    value = "vpc-0bb63223ba82279ae"
  }
}


resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace = "aws-load-balancer-controller"
  # version = "1.14.5"
  create_namespace = false
  cleanup_on_fail = true
  set {
    name  = "source"
    value = "ingress"
  }

  set {
    name  = "domain-filter"
    value = "ahmadkaleem2.link"
  }

  set {
    name = "provider"
    value = "aws"
  }
  set {
    name = "policy"
    value = "upsert-only"
  }
  set {
    name = "aws-zone-type"
    value = "public"
  }
  set {
    name = "registry"
    value = "txt"
  }
  set {
    name = "txt-owner-id"
    value = "asdasd"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io/"
  chart      = "cert-manager"
  namespace = "cert-manager"
  version = "1.15.3"
  create_namespace = true
  cleanup_on_fail = true

  set {
    name = "crds.enabled"
    value = true
  }


}



