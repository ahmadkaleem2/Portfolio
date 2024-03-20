module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpc_config

  vpc_config = each.value

  identifier = var.identifier

  tags_all = {
    Created_by        = var.identifier
    Environment = "${terraform.workspace}"
  }

}

module "bastion_host" {

  source = "./modules/ec2"

  reason = var.ec2.bastion_host.reason

  identifier = var.identifier

  keypair = aws_key_pair.keypair

  security_groups = [module.vpc["vpc-prod"].vpc_security_groups["bastion_security_group"]]

  script_args = var.ec2.bastion_host.script_args

  script_path = var.ec2.bastion_host.script_path

  ami = data.aws_ami.ubuntu.image_id

  instance_type = var.ec2.bastion_host.instance_type

  subnet_for_ec2_instance = module.vpc["vpc-prod"].public_subnets[0]

  tags_all = {
    Name        = var.identifier
    Environment = "${terraform.workspace}"
  }
  
  depends_on = [ module.vpc ]
}

module "mysql_instance" {
  source = "./modules/ec2"

  reason = var.ec2.mysql_instance.reason


  identifier = var.identifier

  keypair = aws_key_pair.keypair

  security_groups = [ aws_security_group.mysql_security_group ]

  script_args = merge(var.ec2.mysql_instance.script_args,{"DB_PASSWORD": aws_ssm_parameter.password_parameter.value})

  script_path = var.ec2.mysql_instance.script_path

  ami = data.aws_ami.ubuntu.image_id

  instance_type = var.ec2.mysql_instance.instance_type

  subnet_for_ec2_instance = module.vpc["vpc-prod"].private_subnets[0]

  tags_all = {
    Name        = var.identifier
    Environment = "${terraform.workspace}"
  }
  
  depends_on = [ module.vpc ]
}


module "asg" {

  source = "./modules/asg"

  vpc = module.vpc["vpc-prod"].vpc

  step_adjustment_scale_up = var.asg.step_adjustment_scale_up

  max_capacity = var.asg.max_capacity
  min_capacity = var.asg.min_capacity

  ami = data.aws_ami.ubuntu.image_id

  instance_type = var.asg.instance_type

  identifier = var.identifier

  public_subnets = module.vpc["vpc-prod"].public_subnets

  private_subnets = module.vpc["vpc-prod"].private_subnets

  region_azs = data.aws_availability_zones.example.names

  vpc_security_groups = module.vpc["vpc-prod"].vpc_security_groups

  key_pair = aws_key_pair.keypair

  DB_SETTINGS = merge(var.ec2.mysql_instance.script_args,{"DB_PASSWORD": aws_ssm_parameter.password_parameter.value})

  mysql_instance = module.mysql_instance.instance

  step_adjustment_scale_down = var.asg.step_adjustment_scale_down


  tags_all = {
    Name        = var.identifier
    Environment = "${terraform.workspace}"
  }

}


