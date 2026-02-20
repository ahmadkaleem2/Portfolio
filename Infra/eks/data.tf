data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "ahmad-terraform-backend1"
    key    = "Infra/networking.tfstate"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "current" {}