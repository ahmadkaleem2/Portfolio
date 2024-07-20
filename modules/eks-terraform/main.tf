

module "deployment" {

    source = "./deployment/"

    # count removed to prevent recreation
    # count = length(local.deployments)
    
    for_each = { for idx, value in local.deployments : "${value.project_name}-${value.deployment_key}" => value}

    # deployment_name = local.deployments[count.index].deployment_key
    # deployment_value = local.deployments[count.index].deployment_value

    deployment_name = each.value.deployment_key
    deployment_value = each.value.deployment_value

}


module "service" {
  source = "./service/"

  
    for_each = { for idx, value in local.services : "${value.project_name}-${value.service_key}" => value}

    service_name = each.value.service_key
    service_value = each.value.service_value



}