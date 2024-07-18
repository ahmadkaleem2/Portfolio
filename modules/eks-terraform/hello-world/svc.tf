resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-example"
  }
  spec {
    selector = {
      test = "fastapi-helloworld"
    }
    
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}