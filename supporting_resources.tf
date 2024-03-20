resource "aws_security_group" "mysql_security_group" {

  name        = "mysql-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc["vpc-prod"].vpc_id

  ingress {
            from_port   = 3306
            protocol    = "tcp"
            to_port     = 3306
            security_groups = [ module.asg.webserver_security_group.id ]
          }

  ingress {
            from_port   = 22
            protocol    = "tcp"
            to_port     = 22
            security_groups = [ module.vpc["vpc-prod"].vpc_security_groups["bastion_security_group"].id ]
          }
  
  egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }

  tags = merge(local.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-sg-mysql"
  })
}


resource "aws_key_pair" "keypair" {
    key_name   = "${terraform.workspace}-${var.identifier}-key"
    public_key = file("./modules/ec2/key.pub")
#   public_key = file("${path.module}/key.pub")
}

resource "random_password" "password_for_database" {
  length = 12
  special = false
}

resource "aws_ssm_parameter" "password_parameter" {
  name  = "/mysql/password"
  type  = "SecureString"
  value = contains(keys(var.ec2.mysql_instance.script_args),"DB_PASSWORD") ? var.ec2.mysql_instance.script_args.DB_PASSWORD : random_password.password_for_database.result
}


