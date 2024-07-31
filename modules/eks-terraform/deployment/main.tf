resource "kubernetes_secret_v1" "deployer_sa_secret" {
  for_each = local.sensitive_env_variables

  metadata {
    name = each.key
  }

  data = each.value.data


  type = each.value.type

}




resource "kubernetes_deployment_v1" "deploy_fastapi" {
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
              for_each = lookup(volume.value, "config_map", {})

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


            dynamic "env_from" {
              for_each = local.sensitive_env_variables

              content {
                secret_ref {
                  name = env_from.key
                }
              }
            }

            # dynamic "env" {

            #   for_each = local.secret_keys

            #   content {
            #     name = env.value.name_in_secret_object
            #     value_from {
            #       secret_key_ref {
            #         name = kubernetes_secret.deployer_sa_secret[env.value.secret_key].metadata[0].name
            #         key  = env.value.name_in_secret_object
            #       }
            #     }

            #   }


            # }



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

            dynamic "port" {
              for_each = lookup(container.value, "ports", {})
              content {
                name           = port.value.name
                container_port = port.value.container_port
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