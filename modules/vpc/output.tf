output "vpc" {
  value = aws_vpc.vpc
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnets" {
  value = aws_subnet.public_subnet
}
output "vpc_security_groups" {
  value = aws_security_group.vpc_security_groups
}
output "public_subnets" {
  value = aws_subnet.public_subnet
}

output "private_subnets" {
  value = aws_subnet.private_subnet
}