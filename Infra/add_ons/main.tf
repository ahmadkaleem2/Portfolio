locals {
  cluster_oidc_issuer_url   = replace(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_iam_role" "albc" {

  name               = "albc-role-${data.terraform_remote_state.eks.outputs.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.cluster_oidc_issuer_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:aws-load-balancer-controller:aws-load-balancer-controller",

          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "albc" {                                                                                                       
  policy = file("${path.module}/custom_policies/load_balancer_controller.json")
  name = "aws_load_balancer_controller_policy"        
}



resource "aws_iam_role_policy_attachment" "albc" {
  role       = aws_iam_role.albc.name
  policy_arn = aws_iam_policy.albc.arn
}


resource "aws_iam_role" "external_dns" {

  name               = "external-dns-role-${data.terraform_remote_state.eks.outputs.cluster_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.cluster_oidc_issuer_url}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.cluster_oidc_issuer_url}:sub" = "system:serviceaccount:external-dns:external-dns",

          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "external_dns" {                                                                                                       
  policy = file("${path.module}/custom_policies/external_dns.json")
  name = "external_dns_policy"        
}



resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}