data "template_file" "wordpress_script" {
  template = file("${path.module}/install-wordpress.sh")

  vars = merge({
    # DB_HOSTNAME = aws_instance.mysql_instance.private_ip
    DB_HOSTNAME = var.mysql_instance.private_ip

  }, var.DB_SETTINGS)
}


data "cloudinit_config" "install-wordpress" {
  gzip          = false
  base64_encode = false


  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.wordpress_script.rendered
  }
} 