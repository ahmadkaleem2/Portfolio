terraform {
  
  backend "s3" {
    bucket = "ahmad-terraform-backend"
    key    = "Infra/networking.tfstate"
    region = "us-west-2"
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 6.0"
    }
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