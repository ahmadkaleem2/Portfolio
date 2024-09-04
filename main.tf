module "vpc" {
  source = "./modules/vpc"

  for_each = local.vpc_config

  vpc_config = each.value

  identifier = var.identifier

  tags_all = {
    Created_by  = var.identifier
    Environment = "${terraform.workspace}"
  }

}

module "eks" {

  source = "./modules/eks"

  identifier = var.identifier

  subnets = module.vpc["vpc-prod"].subnets

  vpc_id = module.vpc["vpc-prod"].vpc_id

  eks_configuration = var.eks_configuration

  tags_all = {
    Created_by  = var.identifier
    Environment = "${terraform.workspace}"
  }

  depends_on = [module.vpc]

}

# module "eks-terraform" {

#   # providers = {
#   #   kubectl = kubectl.gavinbunney_kubectl
#   # }

#   source = "./modules/eks-terraform/"

#   manifests = var.manifests


#   depends_on = [module.eks, module.vpc]
# }

# module "helm" {

#   source = "./modules/helm"

#   eks_cluster_name = module.eks.eks_cluster_name

#   aws_region = var.AWS_REGION
# }




# module "bastion_host" {

#   source = "./modules/ec2"

#   count = length(lookup(module.vpc["vpc-prod"],"private_subnets",[])) > 0 ? 1 : 0

#   reason = var.ec2.bastion_host.reason

#   identifier = var.identifier

#   keypair = var.ec2.bastion_host.key_pair_name

#   security_groups = [module.vpc["vpc-prod"].vpc_security_groups["bastion_security_group"]]

#   script_args = var.ec2.bastion_host.script_args

#   script_path = var.ec2.bastion_host.script_path

#   ami = data.aws_ami.ubuntu.image_id

#   instance_type = var.ec2.bastion_host.instance_type

#   subnet_for_ec2_instance = module.vpc["vpc-prod"].public_subnets[0]

#   tags_all = {
#     Name        = var.identifier
#     Environment = "${terraform.workspace}"
#   }

#   depends_on = [ module.vpc ]
# }

# module "mysql_instance" {
#   source = "./modules/ec2"

#   reason = var.ec2.mysql_instance.reason


#   identifier = var.identifier

#   keypair = var.ec2.mysql_instance.key_pair_name

#   security_groups = [ aws_security_group.mysql_security_group ]

#   script_args = merge(var.ec2.mysql_instance.script_args,{"DB_PASSWORD": aws_ssm_parameter.password_parameter.value})

#   script_path = var.ec2.mysql_instance.script_path

#   ami = data.aws_ami.ubuntu.image_id

#   instance_type = var.ec2.mysql_instance.instance_type

#   subnet_for_ec2_instance = length(lookup(module.vpc["vpc-prod"],"private_subnets",[])) > 0 ? module.vpc["vpc-prod"].private_subnets[0] : module.vpc["vpc-prod"].public_subnets[0]

#   tags_all = {
#     Name        = var.identifier
#     Environment = "${terraform.workspace}"
#   }

#   depends_on = [ module.vpc ]
# }



# module "alb" {
#   source = "./modules/elb"

#   region_azs = data.aws_availability_zones.example.names

#   identifier = var.identifier

#   public_subnets = module.vpc["vpc-prod"].public_subnets

#   vpc_security_groups = module.vpc["vpc-prod"].vpc_security_groups

#   vpc = module.vpc["vpc-prod"].vpc

#   lb_type = var.elb.elb_type

#   listeners = var.elb.listeners

#   target_groups = var.elb.target_groups


# }




# module "asg" {

#   source = "./modules/asg"

#   vpc = module.vpc["vpc-prod"].vpc

#   step_adjustment_scale_up = var.asg.step_adjustment_scale_up

#   max_capacity = var.asg.max_capacity
#   min_capacity = var.asg.min_capacity

#   ami = data.aws_ami.ubuntu.image_id

#   instance_type = var.asg.instance_type

#   identifier = var.identifier

#   public_subnets = module.vpc["vpc-prod"].public_subnets

#   private_subnets = module.vpc["vpc-prod"].private_subnets

#   use_public_subnet_for_asg = length(lookup(module.vpc["vpc-prod"],"private_subnets",[])) == 0 ? true : false 

#   region_azs = data.aws_availability_zones.example.names

#   vpc_security_groups = module.vpc["vpc-prod"].vpc_security_groups


#   key_pair_name = var.asg.key_pair_name

#   mysql_instance = module.mysql_instance.instance

#   step_adjustment_scale_down = var.asg.step_adjustment_scale_down

#   load_balancer = module.alb.load_balancer

#   load_balancer_tg = module.alb.load_balancer_tg

#   asg_script_path = var.asg.user_data_path
#   asg_script_args = merge(var.ec2.mysql_instance.script_args,{"DB_PASSWORD": aws_ssm_parameter.password_parameter.value})

#   tags_all = {
#     Name        = var.identifier
#     Environment = "${terraform.workspace}"
#   }

#   depends_on = [ module.alb ]

# }







