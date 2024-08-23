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

resource "aws_iam_openid_connect_provider" "oidc_eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_issuer.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "example_assume_role_policy" {
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

resource "aws_iam_role" "example" {
  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
  name               = "example-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
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
      "eks.amazonaws.com/role-arn" = aws_iam_role.example.arn
    }
  }
  depends_on = [ kubernetes_namespace.aws-load-balancer-controller ]
}