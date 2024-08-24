data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com", "ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "tls_certificate" "oidc_issuer" {
  url = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "oidc_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:aws-load-balancer-controller:aws-load-balancer-controller"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_eks.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_openid_connect_provider" "oidc_eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_role" "oidc_lbc_role" {
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role_policy.json
  name               = "oidc_lbc_role"
}

resource "aws_iam_policy" "load_balancer_controller" {                                                                                                       
  policy = file("modules/eks/custom_policies/load_balancer_controller.json")
  name = "load_balancer_controller_policy"        
}

resource "aws_iam_role_policy_attachment" "oidc_lbc_role_attachment" {
  policy_arn = aws_iam_policy.load_balancer_controller.arn
  role = aws_iam_role.oidc_lbc_role.name

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