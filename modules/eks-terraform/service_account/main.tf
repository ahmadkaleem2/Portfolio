resource "kubernetes_service_account" "deployer_sa" {
  metadata {
    name = var.service_account_name
  }
}