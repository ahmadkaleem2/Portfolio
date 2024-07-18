resource "kubernetes_config_map" "data_for_app" {
  metadata {
    name = "data-for-app"
  }

  data = {
    whatIsThis             = "thisisterraform"
    
  }
}