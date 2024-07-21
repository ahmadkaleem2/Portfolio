

provider "aws" {
  region = var.AWS_REGION
}

provider "random" {

}

provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data)
  token                  = module.eks.eks_token
}

provider "http" {

}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}


provider "kubectl" {
  alias = "gavinbunney_kubectl"
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.kubeconfig-certificate-authority-data)
  token                  = module.eks.eks_token
}
