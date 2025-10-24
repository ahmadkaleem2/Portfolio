data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "ahmad-terraform-backend"
    key    = "Infra/networking.tfstate"
    region = "us-west-2"
  }
}

data "aws_caller_identity" "current" {}