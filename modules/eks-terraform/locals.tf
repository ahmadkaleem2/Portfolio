locals {

  deployments = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for deployment_key, deployment_value in lookup(manifest_value,"Deployments",{}) : {
        project_name     = manifest_key,
        deployment_key   = deployment_key
        deployment_value = deployment_value
      }
    ]
  ])

  services = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for service_key, service_value in lookup(manifest_value,"services",{}) : {
        project_name  = manifest_key,
        service_key   = service_key
        service_value = service_value
      }
    ]
  ])

  config_maps = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for configmap_key, configmap_value in lookup(manifest_value,"config_maps",{}) : {
        project_name    = manifest_key,
        configmap_key   = configmap_key
        configmap_value = configmap_value
      }
    ]
  ])

  cluster_roles = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for cluster_role_key, cluster_role_value in lookup(manifest_value,"cluster_roles",{}) : {
        project_name    = manifest_key,
        cluster_role_key   = cluster_role_key
        cluster_role_value = cluster_role_value
      }
    ]
  ])

  cluster_role_bindings = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for cluster_role_binding_key, cluster_role_binding_value in lookup(manifest_value,"cluster_role_bindings",{}) : {
        project_name    = manifest_key,
        cluster_role_binding_key   = cluster_role_binding_key
        cluster_role_binding_value = cluster_role_binding_value
      }
    ]
  ])

  service_accounts = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for service_account_key, service_account_value in lookup(manifest_value,"service_accounts",{}) : {
        project_name    = manifest_key,
        service_account_key   = service_account_key
        service_account_value = service_account_value
      }
    ]
  ])
  # lookup(var.manifests,"secrets",{})
  secrets = flatten([
    for manifest_key, manifest_value in var.manifests : [
      for secret_key, secret_value in lookup(manifest_value,"secrets",{}) : {
        project_name    = manifest_key,
        secret_key   = secret_key
        secret_value = secret_value
      }
    ]
  ])


}


# output "deployments" {
#   value = data.kubectl_file_documents.cert_manager_crds.manifests
# }