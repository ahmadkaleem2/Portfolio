data "aws_availability_zones" "example" {
  all_availability_zones = false
}


data "aws_ami" "ubuntu" {


  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20240207.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
