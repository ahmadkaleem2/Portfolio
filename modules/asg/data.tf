data "template_file" "template_script" {
  template = file(var.asg_script_path)

  vars = merge({
    # DB_HOSTNAME = aws_instance.mysql_instance.private_ip
    DB_HOSTNAME = var.mysql_instance.private_ip

  }, var.asg_script_args)
}


data "cloudinit_config" "cloudinit_script" {
  gzip          = false
  base64_encode = false


  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.template_script.rendered
  }
} 