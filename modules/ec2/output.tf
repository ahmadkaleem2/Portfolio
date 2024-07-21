output "aws_ami_selected" {
  value = data.aws_ami.ubuntu
}


output "instance" {
  value = aws_instance.instance
}




