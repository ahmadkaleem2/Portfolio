resource "kubernetes_config_map" "data_for_app" {
  metadata {
    name      = var.configmap_name
    namespace = lookup(var.configmap_value, "namespace", "default")
  }

  data = var.configmap_value.data
}