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
    value = "us-west-2"
  }
  set {
    name = "vpcId"
    value = "vpc-02295c3d9c3e944f2"
  }
}



