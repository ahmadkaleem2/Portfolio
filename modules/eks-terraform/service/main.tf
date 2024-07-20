resource "kubernetes_service" "example" {
  metadata {
    name = var.service_name
  }
  spec {
    selector = var.service_value.selector
    
    dynamic "port" {
      for_each = var.service_value.ports
      content {
        port = port.value.port
        target_port = port.value.port
      }
    }



    # port {
    #   port        = 80
    #   target_port = 80
    # }

    type = var.service_value.type

    # type = "LoadBalancer"
  }
}