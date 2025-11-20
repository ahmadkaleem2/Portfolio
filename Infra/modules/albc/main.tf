



resource "helm_release" "this" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.namespace
  create_namespace = true
  cleanup_on_fail = true

  set = [for k,v in merge(var.albc_values,local.helm_set) : {
    name  = k
    value = v
  }]
}

locals {
  
}