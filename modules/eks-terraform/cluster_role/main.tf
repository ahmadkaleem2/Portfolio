resource "kubernetes_cluster_role" "cluster_role_for_deployment" {
  metadata {
    name = var.cluster_role_name
  }

  dynamic "rule" {
    for_each = var.cluster_role_value.rules
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }

  rule {
    api_groups = ["apps"]
    resources  = ["Deployment"]
    verbs      = ["create", "update"]
  }
}