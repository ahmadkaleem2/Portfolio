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




data "tls_certificate" "oidc_issuer" {
  url = var.cluster_oidc_issuer
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

data "aws_iam_policy_document" "cluster_autoscaler" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_eks.url, "https://", "")}:sub"
      # values   = ["system:serviceaccount:karpenter:karpenter-sa"]
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "eks-cluster-autoscaler-policy"
  description = "IAM policy for EKS Cluster Autoscaler"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "ec2:DescribeImages",
        "ec2:DescribeInstanceTypes",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:GetInstanceTypesFromInstanceRequirements",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup"
      ],
      "Resource": ["*"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_policy_attachment" {
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  role       = aws_iam_role.cluster_autoscaler_iam_role.name
}

resource "aws_iam_role" "cluster_autoscaler_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler.json
  name               = "cluster_autoscaler"
}

resource "aws_iam_role" "example" {
  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
  name               = "example-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.example.name
}

# resource "kubernetes_namespace" "aws-load-balancer-controller" {
#   metadata {
#     annotations = {
#       name = "aws-load-balancer-controller"
#     }

#     labels = {
#       name = "aws-load-balancer-controller"
#     }

#     name = "aws-load-balancer-controller"
#   }
# }

# resource "kubernetes_service_account" "aws_load_balancer_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "aws-load-balancer-controller"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.oidc_lbc_role.arn
#     }
#   }
#   depends_on = [ kubernetes_namespace.aws-load-balancer-controller ]
# }









data "aws_iam_policy_document" "cluster_karpenter" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc_eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:karpenter:karpenter-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc_eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "cluster_karpenter_policy" {
  name        = "eks-cluster-karpenter-policy"
  description = "IAM policy for EKS Cluster Autoscaler"
  policy      = <<EOF
{
    "Statement": [
        {
            "Action": [
                "iam:RemoveRoleFromInstanceProfile",
                "ec2:TerminateInstances",
                "iam:DeleteInstanceProfile",
                "iam:PassRole",
                "iam:AddRoleToInstanceProfile",
                "iam:TagInstanceProfile",
                "iam:GetInstanceProfile",
                "iam:CreateInstanceProfile",
                "ssm:GetParameter",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },

        {
            "Effect": "Allow",
            "Action": "eks:DescribeCluster",
            "Resource": "arn:aws:eks:us-west-2:680688655542:cluster/*",
            "Sid": "EKSClusterEndpointLookup"
        }
    ],
    "Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "cluster_karpenter_policy_attachment" {
  policy_arn = aws_iam_policy.cluster_karpenter_policy.arn
  role       = aws_iam_role.cluster_karpenter_iam_role.name
}

resource "aws_iam_role" "cluster_karpenter_iam_role" {
  assume_role_policy = data.aws_iam_policy_document.cluster_karpenter.json
  name               = "cluster_karpenter"
}










resource "aws_iam_openid_connect_provider" "oidc_eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_issuer.certificates[0].sha1_fingerprint]
  url             = var.cluster_oidc_issuer
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