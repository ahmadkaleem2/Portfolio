resource "kubernetes_deployment" "deploy_fastapi" {
  metadata {
    name      = var.deployment_name
    labels    = var.deployment_value.labels
    namespace = lookup(var.deployment_value, "namespace", "default")


  }

  spec {
    replicas = var.deployment_value.replicas



    selector {
      match_labels = var.deployment_value.selector.match_labels

    }

    template {
      metadata {
        labels = var.deployment_value.template.metadata.labels
      }

      spec {


        dynamic "volume" {
          for_each = lookup(var.deployment_value.template.spec, "volume", {})
          content {
            name = volume.value.name
            dynamic "config_map" {
              for_each = lookup(volume.value,"config_map",{})
              
              content {
                name = config_map.value
                  
              }
              
            }
            
            
            # name = volume.value.name
            # config_map {
            #   name = volume.value.config_map.name
            # }
          }
        }

        # volume {
        #   name = "app-data"
        #   config_map {
        #     name = "data-for-app"
        #   }
        # }

        dynamic "container" {
          for_each = var.deployment_value.template.spec.container
          content {
            image = container.value.image
            name  = container.value.name

            resources {
              limits   = container.value.resources.limits
              requests = container.value.resources.requests
            }
            dynamic "volume_mount" {
              for_each = lookup(container.value, "volume_mounts", {})
              # for_each = container.value.volume_mounts
              content {
                name       = volume_mount.value.name
                mount_path = volume_mount.value.mount_path
              }
            }
          }
        }
      }
    }
  }
  timeouts {
    create = "30s"
    update = "60s"
    delete = "60s"
  }
}