

module "deployment" {

  source = "./deployment/"

  # count removed to prevent recreation
  # count = length(local.deployments)

  for_each = { for idx, value in local.deployments : "${value.project_name}-${value.deployment_key}" => value }


  deployment_name  = each.value.deployment_key
  deployment_value = each.value.deployment_value

}


module "service" {
  source = "./service/"

  for_each = { for idx, value in local.services : "${value.project_name}-${value.service_key}" => value }

  service_name  = each.value.service_key
  service_value = each.value.service_value

}

module "config_map" {
  source = "./config_map"

  for_each = { for idx, value in local.config_maps : "${value.project_name}-${value.configmap_key}" => value }

  configmap_name  = each.value.configmap_key
  configmap_value = each.value.configmap_value

}

module "cluster_roles" {

  source = "./cluster_role"

  for_each = { for idx, value in local.cluster_roles : "${value.project_name}-${value.cluster_role_key}" => value }

  cluster_role_name  = each.value.cluster_role_key
  cluster_role_value = each.value.cluster_role_value



}

module "cluster_role_bindings" {

  source = "./cluster_role_binding"

  for_each = { for idx, value in local.cluster_role_bindings : "${value.project_name}-${value.cluster_role_binding_key}" => value }

  cluster_role_binding_name  = each.value.cluster_role_binding_key
  cluster_role_binding_value = each.value.cluster_role_binding_value



}

module "service_accounts" {

  source = "./service_account"

  for_each = { for idx, value in local.service_accounts : "${value.project_name}-${value.service_account_key}" => value }

  service_account_name  = each.value.service_account_key
  service_account_value = each.value.service_account_value




}

module "secrets" {


  source = "./secret"


  for_each = { for idx, value in local.secrets : "${value.project_name}-${value.secret_key}" => value }

  secret_name  = each.value.secret_key
  secret_value = each.value.secret_value


}




# # We use the for_each or else this kubectl_manifest will only import the first manifest in the file.
# resource "kubectl_manifest" "cert_manager_crds" {
#   for_each  = data.kubectl_file_documents.cert_manager_crds.manifests
#   yaml_body = each.value
# }




# # We use the for_each or else this kubectl_manifest will only import the first manifest in the file.
# resource "kubectl_manifest" "gateway_api_crds" {
#   for_each  = data.kubectl_file_documents.gateway_api_crds.manifests
#   yaml_body = each.value

# }