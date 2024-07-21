resource "kubernetes_cluster_role" "cluster_role_for_deployment" {
  metadata {
    name = "deploymentRole"
  }

  rule {
    api_groups = ["apps"]
    resources  = ["Deployment"]
    verbs      = ["create", "update"]
  }
}


resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "roleToSaBinder"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "deploymentRole"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "deploy-sa"
    namespace = "kube-system"
  }

}