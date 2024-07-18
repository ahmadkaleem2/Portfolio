






resource "aws_eks_cluster" "eks-cluster" {
  name     = var.cluster_name == null? "${terraform.workspace}-${var.identifier}-EKS" : var.cluster_name 
  role_arn = aws_iam_role.eks-role.arn
  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  vpc_config {
    subnet_ids = local.subnet_ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}






resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "node_group1"
  node_role_arn   = aws_iam_role.ahmad-eks-node-role.arn
  subnet_ids      = local.subnet_ids
  capacity_type = "SPOT"
  instance_types = ["t3.large"]
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}