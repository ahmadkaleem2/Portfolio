



resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.namespace
  create_namespace = true
  cleanup_on_fail = true

  dynamic "set" {
    for_each = var.albc_values
    content {
      name  = each.key
      value = each.value
    }
  }
}