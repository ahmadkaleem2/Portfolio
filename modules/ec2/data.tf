data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



# data "template_file" "mysql_script" {
#   template = file("${path.module}/install-mysql.sh")

#   vars = var.DB_SETTINGS
# }

# data "cloudinit_config" "cloudinit-example" {
#   gzip          = false
#   base64_encode = false


#   part {
#     content_type = "text/x-shellscript"
#     content      = data.template_file.mysql_script.rendered
#   }
# } 

data "template_file" "script" {
  # template = file("${path.module}/install-mysql.sh")
  count    = var.script_path != "" ? 1 : 0
  template = file(var.script_path)
  vars = var.script_args

  # vars = var.DB_SETTINGS
}

data "cloudinit_config" "cloudinit-example" {
  
  count    = var.script_path != "" ? 1 : 0
  
  gzip          = false
  base64_encode = false


  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.script[0].rendered
  }
} 

