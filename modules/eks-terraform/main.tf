




module "deployment" {


    source = "./deployment/"

    # count removed to prevent recreation
    # count = length(local.deployments)

    for_each = { for idx, value in local.deployments : value.deployment_key => value}


    

    # deployment_name = local.deployments[count.index].deployment_key
    # deployment_value = local.deployments[count.index].deployment_value

    deployment_name = each.value.deployment_key
    deployment_value = each.value.deployment_value


    
  


}