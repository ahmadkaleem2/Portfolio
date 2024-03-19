output "list_of_azs" {
  value = data.aws_availability_zones.example.names
}


output "terraformworkspace" {
  value = terraform.workspace
}





# output "aws_ami" {
#   value = module.ec2.aws_ami_selected
# }

output "vpc" {
  value = module.vpc
}

output "vpc_id" {
  value = module.vpc["vpc-prod"].vpc_id
}
# output "mysql_sg" {
#   value = module.vpc["vpc-prod"].sgs["mysql_sg"]
# }

# output "alb_sg" {
#   value = module.vpc["vpc-prod"].sgs["alb_sg"]
# }

# output "alb_sg" {
#   value = module.vpc["vpc-prod"].sgs["alb_sg"]
# }

# output "vpc_subnet" {
#   value = module.vpc["vpc-prod"]
# }

# output "private_ip_of_mysql_instance" {
#   value = module.ec2.private_ip_of_mysql
# }

# output "user_data_lt" {
#   value = module.asg.user_data_lt
# }