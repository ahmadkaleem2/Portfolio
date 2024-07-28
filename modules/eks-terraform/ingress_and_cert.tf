
# data "http" "cert_manager_url" {
#   url = "https://github.com/cert-manager/cert-manager/releases/download/v1.15.1/cert-manager.yaml"
# }


# data "http" "gateway_api_url" {
#   url = "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.1.0/standard-install.yaml"
# }

# data "kubectl_file_documents" "cert_manager_crds" {
#   content = data.http.cert_manager_url.response_body

# }



# data "kubectl_file_documents" "gateway_api_crds" {
#   content = data.http.gateway_api_url.response_body

# }

# # We use the for_each or else this kubectl_manifest will only import the first manifest in the file.
# resource "kubectl_manifest" "cert_manager_crds" {
#   for_each  = data.kubectl_file_documents.cert_manager_crds.manifests
#   yaml_body = each.value
# }




# # # We use the for_each or else this kubectl_manifest will only import the first manifest in the file.
# resource "kubectl_manifest" "gateway_api_crds" {
#   for_each  = data.kubectl_file_documents.gateway_api_crds.manifests
#   yaml_body = each.value  
# }