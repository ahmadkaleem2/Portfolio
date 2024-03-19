resource "aws_security_group" "mysql_sg" {

  name        = "mysql-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = module.vpc["vpc-prod"].vpc_id

  ingress {
            from_port   = 3306
            protocol    = "tcp"
            to_port     = 3306
            security_groups = [ module.asg.webserver_sg.id ]
          }

  ingress {
            from_port   = 22
            protocol    = "tcp"
            to_port     = 22
            security_groups = [ module.vpc["vpc-prod"].vpc_sgs["bastion_sg"].id ]
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