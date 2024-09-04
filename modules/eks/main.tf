
resource "aws_eks_cluster" "eks-cluster" {
  name     = lookup(var.eks_configuration, "cluster_name", "${terraform.workspace}-${var.identifier}-EKS")
  role_arn = var.eks_configuration.eks_cluster_iam_role_arn == null ? aws_iam_role.eks-role.arn : aws_iam_role.eks-role.arn

  access_config {
    authentication_mode                         = local.access_config.authentication_mode
    bootstrap_cluster_creator_admin_permissions = local.access_config.bootstrap_cluster_creator_admin_permissions
  }
  vpc_config {
    subnet_ids = local.subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}


resource "aws_eks_addon" "eks_addons" {
  count = length(var.eks_configuration.eks_addons)
  cluster_name = aws_eks_cluster.eks-cluster.name
  addon_name   = var.eks_configuration.eks_addons[count.index]

  depends_on = [ aws_eks_node_group.eks_node_groups ]
}

resource "aws_eks_node_group" "eks_node_groups" {

  for_each = local.nodegroups

  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = each.key
  node_role_arn   = each.value.node_role_arn == null ? aws_iam_role.ahmad-eks-node-role.arn : each.value.node_role_arn
  subnet_ids      = local.subnet_ids
  capacity_type   = each.value.capacity_type
  instance_types  = each.value.instance_types

  disk_size = each.value.disk_size

  labels = each.value.labels




  dynamic "taint" {
    for_each = each.value.taints

    content {
      key    = taint.key
      effect = taint.value.effect
      value  = taint.value.value
    }
  }


  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = each.value.update_config.max_unavailable
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"       = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks-cluster.name}" = "owned"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}


module "helm" {

  source = "./helm"

  eks_cluster_name = aws_eks_cluster.eks-cluster.name

  eks_cluster_endpoint = aws_eks_cluster.eks-cluster.endpoint

  AWS_REGION = "us-west-2"

  cluster_oidc_issuer = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
  
}