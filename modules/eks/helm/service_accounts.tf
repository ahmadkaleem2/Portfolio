# resource "kubernetes_service_account" "karpenter" {
#   metadata {
#     name      = "karpenter-sa"
#     namespace = "karpenter"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_iam_role.arn
#     }
#   }
#   depends_on = [ kubernetes_namespace.karpenter_ns ]
# }

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


# resource "kubernetes_service_account" "external_dns" {
#   metadata {
#     name      = "external-dns"
#     namespace = "external-dns"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.external_dns_iam_role.arn
#     }
#   }
#   depends_on = [ kubernetes_namespace.external-dns]
# }