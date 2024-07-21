
resource "aws_instance" "instance" {
  ami           = var.ami
  instance_type = var.instance_type

  # subnet_id     = var.private_subnets[0].id
  subnet_id = var.subnet_for_ec2_instance.id

  user_data = length(data.cloudinit_config.cloudinit-example) > 0 ? data.cloudinit_config.cloudinit-example[0].rendered : ""

  key_name = "ahmad-terraform-key"

  vpc_security_group_ids = [for i in var.security_groups : i.id]
  # vpc_security_group_ids = [ aws_security_group.mysql_sg.id ]
  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-${var.reason}"

  })
}





























# resource "aws_instance" "bastion_host" {
#   ami           = var.ami
#   instance_type = var.instance_type

#   vpc_security_group_ids = [ var.sgs["bastion_sg"].id  ]
#   subnet_id = var.public_subnets[0].id
#   key_name = aws_key_pair.mykeypair.key_name
#   tags = merge(var.tags_all,{
#     Name = "${terraform.workspace}-${var.identifier}-bastion-host"
#   })
# }



# resource "aws_instance" "mysql_instance" {
#   ami           = var.ami
#   instance_type = var.instance_type

#   subnet_id     = var.private_subnets[0].id

#   user_data = "${data.cloudinit_config.cloudinit-example.rendered}"

#   key_name = aws_key_pair.mykeypair.key_name


#   vpc_security_group_ids = [ aws_security_group.mysql_sg.id ]
#   tags = merge(var.tags_all,{
#     Name = "${terraform.workspace}-${var.identifier}-mysql"
#     Reason = "mysql_instance"
#   })


#   depends_on = [ var.vpc_nat_gateway ]

# }

# resource "aws_key_pair" "mykeypair" {
#   key_name   = "${terraform.workspace}-${var.identifier}-key"
#   public_key = file("${path.module}/key.pub")
# }



# resource "aws_security_group" "mysql_sg" {

#   name        = "mysql-sg"
#   description = "Allow TLS inbound traffic and all outbound traffic"
#   vpc_id      = var.vpc.id

#   ingress {
#             from_port   = 3306
#             protocol    = "tcp"
#             to_port     = 3306
#             security_groups = [ var.webserver_sg.id ]
#           }

#   ingress {
#             from_port   = 22
#             protocol    = "tcp"
#             to_port     = 22
#             security_groups = [ var.sgs["bastion_sg"].id ]
#           }

#   egress {
#             from_port   = 0
#             to_port     = 0
#             protocol    = "-1"
#             cidr_blocks = ["0.0.0.0/0"]
#           }



#   tags = merge(var.tags_all, {
#     Name = "${terraform.workspace}-${var.identifier}-sg-mysql"
#   })
# }







