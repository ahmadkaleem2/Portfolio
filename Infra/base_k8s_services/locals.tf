locals {

  albc_values = {
    "serviceAccount.create" = "true",
    "serviceAccount.name"   = "aws-load-balancer-controller",
    "clusterName"           = data.terraform_remote_state.eks.outputs.cluster_name,
    "region"                = "us-west-2",
    "vpcId"                 = data.terraform_remote_state.vpc.outputs.vpc_id
  }

  folder_array = split("/", abspath("."))
  
  created_by = join("/", ["https://github.com/ahmadkaleem2"], slice(local.folder_array, index(local.folder_array, "Portfolio"), length(local.folder_array)))
}