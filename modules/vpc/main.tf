resource "aws_vpc" "main" {
  cidr_block           = var.vpc_config.VPC_CIDR_BLOCK
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-vpc"
  })
}


resource "aws_subnet" "public_subnet" {

  count = length(var.vpc_config.public_subnets)

  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  enable_resource_name_dns_a_record_on_launch = true
  # availability_zone                           = var.vpc_config.public_subnet_azs[count.index]
  # cidr_block                                  = var.vpc_config.public_subnets[count.index]

  availability_zone                           = element(var.vpc_config.public_subnet_azs, count.index)
  cidr_block                                  = element(var.vpc_config.public_subnets, count.index)



  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-public-subnet"
    Type = "public_subnet"
  })
}

resource "aws_subnet" "private_subnet" {
  count = length(var.vpc_config.private_subnets)


  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false


  enable_resource_name_dns_a_record_on_launch = false
  availability_zone                           = element(var.vpc_config.private_subnet_azs, count.index)
  cidr_block                                  = element(var.vpc_config.private_subnets, count.index)

  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-private-subnet"
    Type = "private_subnet"
  })
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags_all, {
  Name = "${terraform.workspace}-${var.identifier}-igw"
  })
}



resource "aws_route_table" "public_route_table" {

  count = length(aws_subnet.public_subnet)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-public-rt"
    Type = "public"
  })
}



resource "aws_route_table_association" "public_route_table_associations" {
  count = length(aws_subnet.public_subnet)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}






resource "aws_eip" "eip_for_nat" {

  domain = "vpc"

  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-eip"
  })
}


resource "aws_nat_gateway" "nat_gateway_for_private_subnets" {
  subnet_id = aws_subnet.public_subnet[0].id


  allocation_id = aws_eip.eip_for_nat.id


  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-nat-gateway"
  })

  depends_on = [aws_internet_gateway.gw]#, aws_eip.example]
}


resource "aws_route_table" "private" {

  count = length(aws_subnet.private_subnet)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_for_private_subnets.id
  }

  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-private-rt"
    Type = "Private"
  })
}

resource "aws_route_table_association" "private" {

  count = length(aws_subnet.private_subnet)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private[count.index].id

}

resource "aws_security_group" "vpc_sgs" {

  for_each    = var.vpc_config.security_groups
  name        = each.key
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port       = ingress.value.from_port
      protocol        = ingress.value.protocol
      to_port         = ingress.value.to_port
      security_groups = try(ingress.value.security_groups, null)
      cidr_blocks     = try(ingress.value.cidr_blocks, null)
      # security_groups = length(ingress.value.cidr_blocks) == 0 && length(ingress.value.security_groups) > 0 ? ingress.value.security_groups : null
      # cidr_blocks = length(ingress.value.cidr_blocks) > 0 && length(ingress.value.security_groups) == 0 ? ingress.value.cidr_blocks : null
    }
  }
  dynamic "egress" {
    for_each = each.value.egress
    content {
      from_port   = egress.value.from_port
      cidr_blocks = egress.value.cidr_blocks
      protocol    = egress.value.protocol
      to_port     = egress.value.to_port
    }
  }



  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-sg"
  })
}

