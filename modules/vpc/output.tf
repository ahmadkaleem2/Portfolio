# output "subnets" {
#   value = keys(aws_subnet.subnets)
# }

output "vpc" {
  value = aws_vpc.main
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets" {
  value = aws_subnet.public_subnet
}



output "vpc_sgs" {
  value = aws_security_group.vpc_sgs
}



output "public_subnets" {
  value = aws_subnet.public_subnet
}

output "private_subnets" {
  value = aws_subnet.private_subnet
}

output "vpc_nat_gateway" {
  value = aws_nat_gateway.nat_gateway_for_private_subnets
}