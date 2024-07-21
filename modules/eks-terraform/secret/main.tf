
resource "kubernetes_secret" "deployer_sa_secret" {
  metadata {
    annotations = var.secret_value.annotations

    name = var.secret_name
  }

  type                           = var.secret_value.type
  wait_for_service_account_token = var.secret_value.wait_for_service_account_token
}