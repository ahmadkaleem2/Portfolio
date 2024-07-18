resource "kubernetes_deployment" "deploy_fastapi" {
  metadata {
    name = "fastapi-helloworld-deployment"
    labels = {
      test = "fastapi-helloworld"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "fastapi-helloworld"
      }
    }

    template {
      metadata {
        labels = {
          test = "fastapi-helloworld"
        }
      }

      spec {
        volume {
          name = "app-data"
          config_map {
            name = "data-for-app"
          }
        }
        container {
          image = "489994096722.dkr.ecr.us-west-1.amazonaws.com/fastapi-helloworld-project"
          name  = "fastapi-helloworld"
          volume_mount {
            name = "app-data"
            mount_path = "/etc/data123"
          }
          
          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

            }

            initial_delay_seconds = 5
            period_seconds        = 3
          }
        }
      }
    }
  }
}