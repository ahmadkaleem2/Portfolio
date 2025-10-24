data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "ahmad-terraform-backend"
    key    = "Infra/networking.tfstate"
    region = "us-west-2"
  }
}

data "terraform_remote_state" "eks" {
  backend = "s3"

  config = {
    bucket = "ahmad-terraform-backend"
    key    = "Infra/EKS.tfstate"
    region = "us-west-2"
  }
}
