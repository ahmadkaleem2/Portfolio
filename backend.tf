terraform {
  backend "s3" {
    bucket         = "terraform-backend-to-store-remote-state-file"
    key            = "terraform.tfstate"
    # dynamodb_table = "terraform-lock"
    region         = "us-west-1"
  }
}
