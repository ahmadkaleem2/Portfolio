resource "kubernetes_service_account" "deployer_sa" {
  metadata {
    name = "deploy-sa"
  }
}

resource "kubernetes_secret" "deployer_sa_secret" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.deployer_sa.metadata[0].name
    }

    name = "deployer-sa-secret"
  }

  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true
}