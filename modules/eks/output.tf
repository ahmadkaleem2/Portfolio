output "endpoint" {
  value = aws_eks_cluster.eks-cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name = aws_eks_cluster.eks-cluster.name
}

output "eks_token" {
  value = data.aws_eks_cluster_auth.eks_cluster_auth.token
}

output "cluster_name" {
  value = aws_eks_cluster.eks-cluster.name
}