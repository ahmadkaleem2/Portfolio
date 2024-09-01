

output "terraform_workspace" {
  value = terraform.workspace
}

# output "vpc" {
#   value = module.vpc
# }

output "vpc_id" {
  value = module.vpc["vpc-prod"].vpc_id
}

# output "vpc_config" {

#     value = local.vpc_config

# }

# output "alb_dns_name" {
#   value = module.alb.load_balancer.dns_name
# }

output "list_of_azs" {
  value = data.aws_availability_zones.example.names
}

# output "ecr_object" {
#   value = module.ecr
# }

output "deployments" {
  value = module.eks-terraform.deployments
}

# output "va" {
#   value = module.eks-terraform.va
# }

output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${module.eks.eks_cluster_name} --region ${var.AWS_REGION}"
}