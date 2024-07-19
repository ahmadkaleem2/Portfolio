locals {
  
  deployments = flatten([
    for manifest_key, manifest_value in var.manifests : [
        for deployment_key, deployment_value in manifest_value.Deployments : {
            project_name = manifest_key,
            deployment_key = deployment_key
            deployment_value = deployment_value

        }

    ]
  ])




}


output "deployments" {
  value = local.deployments
}