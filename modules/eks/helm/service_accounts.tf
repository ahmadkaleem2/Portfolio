resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter-sa"
    namespace = "karpenter"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::680688655542:role/cluster_karpenter"
    }
  }
  depends_on = [ kubernetes_namespace.karpenter_ns ]
}

resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "aws-load-balancer-controller"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.oidc_lbc_role.arn
    }
  }
  depends_on = [ kubernetes_namespace.aws-load-balancer-controller ]
}