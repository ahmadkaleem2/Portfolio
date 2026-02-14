provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks_cluster_auth.token
    # exec {
    #   api_version = "client.authentication.k8s.io/v1beta1"
    #   args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
    #   command     = "aws"
    # }
  }
}



provider "kubernetes" {
    host                   = aws_eks_cluster.eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks-cluster.certificate_authority[0].data)
    token = data.aws_eks_cluster_auth.eks_cluster_auth.token
}