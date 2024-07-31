
resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = var.cluster_role_binding_name
  }

  dynamic "role_ref" {
    for_each = var.cluster_role_binding_value.role_ref
    content {
      # only possible value
      api_group = "rbac.authorization.k8s.io"
      kind      = role_ref.value.kind
      name      = role_ref.value.name
    }
  }

  dynamic "subject" {
    for_each = var.cluster_role_binding_value.subject
    content {
      kind      = subject.value.kind
      name      = subject.value.name
      namespace = subject.value.namespace
    }
  }

  # role_ref {
  #   api_group = "rbac.authorization.k8s.io"
  #   kind      = "ClusterRole"
  #   name      = "deploymentRole"
  # }
  # subject {
  #   kind      = "ServiceAccount"
  #   name      = "deploy-sa"
  #   namespace = "kube-system"
  # }

}