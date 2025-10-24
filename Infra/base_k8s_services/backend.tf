terraform {
  
  backend "s3" {
    bucket = "ahmad-terraform-backend"
    key    = "Infra/base_k8s_services.tfstate"
    region = "us-west-2"
  }
  
}


provider "aws" {
  region = "us-west-2"


  default_tags {
    tags = {
      created_by = local.created_by
      
    }
  }
  
}