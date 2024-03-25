resource "aws_security_group" "mysql_security_group" {

  name        = "mysql-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc["vpc-prod"].vpc_id
  
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



resource "aws_security_group_rule" "rds_sg" {

  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"

  source_security_group_id = module.asg.webserver_security_group.id
  security_group_id = aws_security_group.mysql_security_group.id

}

resource "aws_security_group_rule" "allow_traffic_from_bastion_host" {

  count = length(lookup(module.vpc["vpc-prod"],"private_subnets",[])) > 0 ? 1 : 0

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"



  source_security_group_id = module.vpc["vpc-prod"].vpc_security_groups["bastion_security_group"].id
  security_group_id = aws_security_group.mysql_security_group.id


}

resource "random_password" "password_for_database" {
  length = 12
  special = false
}

resource "aws_ssm_parameter" "password_parameter" {
  name  = "/${terraform.workspace}/mysql/password"
  type  = "SecureString"
  value = contains(keys(var.ec2.mysql_instance.script_args),"DB_PASSWORD") ? var.ec2.mysql_instance.script_args.DB_PASSWORD : random_password.password_for_database.result
}


