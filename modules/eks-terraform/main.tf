




module "deployment" {


    source = "./deployment/"

    # for_each = local.deployments
    count = length(local.deployments)


    deployment_name = local.deployments[count.index].deployment_key
    deployment_value = local.deployments[count.index].deployment_value

    


    
  


}