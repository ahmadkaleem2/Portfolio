
locals {
    # vpc_config = { for k,v in var.vpcs : k=>v if v.enabled==true}
    vpc_config = { for k,v in var.vpcs : k=>merge(v,{
        "public_subnet_azs"=data.aws_availability_zones.example.names
        "private_subnet_azs"=data.aws_availability_zones.example.names
        }) if v.enabled==true}
    tags_all = {
        Name        = var.identifier
        Environment = "${terraform.workspace}"
                }
}


output "vpc_config" {

    value = local.vpc_config
  
}


