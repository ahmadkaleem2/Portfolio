# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace = "aws-load-balancer-controller"
#   create_namespace = false
#   cleanup_on_fail = true
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name = "clusterName"
#     value = var.eks_cluster_name
#   }
#   set {
#     name = "region"
#     value = "us-west-2"
#   }
#   set {
#     name = "vpcId"
#     value = "vpc-02295c3d9c3e944f2"
#   }
# }

# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = var.eks_cluster_name
#   }

#   set {
#     name  = "awsRegion"
#     value = "us-west-2"  # Assuming you have this variable defined
#   }

#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = "arn:aws:iam::489994096722:role/cluster_autoscaler"
#   }

#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "rbac.serviceAccount.name"
#     value = "cluster-autoscaler"
#   }
# }

resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "karpenter"
  create_namespace = false

  chart      = "oci://public.ecr.aws/karpenter/karpenter"
  # version    = var.karpenter_version

  set {
    name  = "settings.clusterName"
    value = var.eks_cluster_name
  }

  set {
    name  = "settings.interruptionQueue"
    # value = var.eks_cluster_name
    value = ""

  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "karpenter-sa"
  }
  set {
    name = "controller.clusterEndpoint"
    value = "https://11444CBBECEB8B4E47B5F48607359428.gr7.us-west-2.eks.amazonaws.com"
  }

  wait = true
}

resource "kubernetes_namespace" "karpenter_ns" {
  metadata {
    name = "karpenter"
  }
  
}

resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter-sa"
    namespace = "karpenter"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::489994096722:role/cluster_karpenter"
    }
  }
  depends_on = [ kubernetes_namespace.karpenter_ns ]
}



