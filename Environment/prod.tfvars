AWS_REGION = "us-west-2"
identifier = "Ahmad"
vpcs = {
  vpc-dev = {
    enabled        = false
    VPC_CIDR_BLOCK = "10.0.0.0/16"
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

    private_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

    security_groups = {
      webserver_sg = {
        ingress = [
          {
            from_port   = 443
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 443

          },
          {
            from_port   = 80
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 80

          },
          {
            from_port   = 22
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 22

          }
        ],
        egress = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
      apache_kafka_server = {
        ingress = [
          {
            from_port   = 443
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 443

          },
          {
            from_port   = 22
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 22

          }
        ],
        egress = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
    }
  },
  vpc-prod = {
    enabled        = true
    VPC_CIDR_BLOCK = "10.0.0.0/16"
    public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

    private_subnets = []

    security_groups = {
      bastion_security_group = {
        ingress = [


          {
            from_port   = 22
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 22

          }
        ],
        egress = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
      alb_security_group = {
        ingress = [
          {
            from_port   = 443
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 443
          },
          {
            from_port   = 80
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 80

          },
        ],
        egress = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
      mysql_sg = {
        ingress = [

          {
            from_port   = 3306
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 3306

          }
        ],
        egress = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
      apache_kafka_server = {
        ingress = [
          {
            from_port   = 443
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 443

          },
          {
            from_port   = 22
            cidr_blocks = ["0.0.0.0/0"]
            protocol    = "tcp"
            to_port     = 22

          }
        ],
        egress = [
          {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
      }
    }
  }

}

ec2 = {


  bastion_host = {

    key_pair_name = "ahmad-terraform-key"

    reason = "bastion_host"

    script_args = {}
    script_path = ""

    instance_type = "t2.micro"

  }

  mysql_instance = {

    key_pair_name = "ahmad-terraform-key"

    reason = "mysql_instance"

    script_args = {
      DB_USERNAME = "wordpress"
      DB_NAME     = "wordpress"
    }

    script_path = "./scripts/install-mysql.sh"

    instance_type = "t2.micro"



  }

}

asg = {

  key_pair_name = "ahmad-terraform-key"

  user_data_path = "./scripts/install-wordpress.sh"

  instance_type = "t2.micro"
  min_capacity  = 1
  max_capacity  = 4
  step_adjustment_scale_up = [
    {
      metric_interval_upper_bound = null
      scaling_adjustment          = 3
      metric_interval_lower_bound = 25
    },

    {
      metric_interval_upper_bound = 25
      scaling_adjustment          = 2
      metric_interval_lower_bound = 0
    }

  ]
  step_adjustment_scale_down = [
    {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -2
      metric_interval_lower_bound = -10
    },

    {
      metric_interval_upper_bound = -10
      scaling_adjustment          = -1
      metric_interval_lower_bound = -20
    }
    ,
    {
      metric_interval_upper_bound = -20
      scaling_adjustment          = -1
      metric_interval_lower_bound = null
    }
  ]
}


elb = {
  elb_type = "application"


  listeners = {
    ######
    #   LISTENERS TLS AND TCP are only applicable to elb_type = "network" and 
    #   LISTENERS HTTP AND HTTPS are only applicable to elb_type = "application"
    ######

    # http_listener = {

    #   port = 80
    #   protocol = "TCP"
    #   target_group_name = "wordpress-tg" 
    # },

    # https_listener = {

    #   port = 443
    #   protocol = "TLS"
    #   target_group_name = "wordpress-tg" 
    #   certificate_arn = "dummy_arn"


    # }

    http_listener = {

      port              = 80
      protocol          = "HTTP"
      target_group_name = "wordpress-tg"
    },

    # https_listener = {

    #   port = 443
    #   protocol = "HTTPS"
    #   target_group_name = "wordpress-tg" 
    #   certificate_arn = "dummy_arn"


    # }


  }
  target_groups = {
    "wordpress-tg" = {
      port                   = 80
      protocol               = "HTTP"
      health_check_path      = "/"
      health_check_threshold = 2
      unhealthy_threshold    = 5
      timeout                = 45
      interval               = 60
      matcher                = "200-302"
    }
  }


}

eks_configuration = {

  eks_cluster_iam_role_arn = null

  access_config = {
    # possible value ["CONFIG_MAP", "API_AND_CONFIG_MAP", "API"]
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  node_groups = {
    "ng1" = {
      node_group_name = "ng1"
      node_role_arn   = null
      capacity_type   = "SPOT"
      instance_types  = ["t3.medium"]
      disk_size       = 20

      labels = {
        "node" : "ng1"
        "arch" : "amd64"
      }
      taints = {
        "mospel" = {
          value  = "mosquito"
          effect = "PREFER_NO_SCHEDULE"
        }
      }

      scaling_config = {
        desired_size = 1
        max_size     = 1
        min_size     = 1

      }
      update_config = {
        max_unavailable = 1
      }
    }
    # "ng2" = {
    #   node_group_name = "ng2"
    #   node_role_arn = null
    #   capacity_type = "SPOT"
    #   instance_types = ["t3.small"]
    #   disk_size = 20

    #   labels = {
    #     "node": "ng2"
    #     "arch": "amd64"
    #   }
    #   taints = {
        
    #   }

    #   scaling_config = {
    #     desired_size = 1
    #     max_size = 1
    #     min_size = 1

    #   }
    #   update_config = {
    #     max_unavailable = 1
    #   }
    # }
  }
}







manifests = {

  hello-world = {


    secrets = {

      deployer-sa-secret = {

        annotations = {
          "kubernetes.io/service-account.name" = "deploy-sa"
        }

        type                           = "kubernetes.io/service-account-token"
        wait_for_service_account_token = true


      }

    }


    service_accounts = {

      deploy-sa = {

      }

    }




    cluster_role_bindings = {
      roleToSaBinder = {
        role_ref = [
          {
          api_group = "rbac.authorization.k8s.io"
          kind      = "ClusterRole"
          name      = "deploymentRole"
          }
        ]
        subject = [
          {
            kind      = "ServiceAccount"
            name      = "deploy-sa"
            namespace = "kube-system"
          }
        ]
      }
    }

    cluster_roles = {

      deploymentRole = {

        rules = [
          {
            api_groups = ["apps"]
            resources  = ["Deployment"]
            verbs      = ["create", "update"]
          }
        ]
      }

    }


    config_maps = {

      data-for-app = {

        namespace = "default"

        data = {

          whatIsThis = "thisisterraform"

        }

      }

    }



    services = {

      fastapi-helloworld = {

        selector = {
          test = "fastapi-helloworld"
        }

        ports = [
          {
            port        = 80
            target_port = 80
          }
        ]

        type = "ClusterIP"


      }


    }

    Deployments = {
      fastapi-helloworld-deployment = {

        labels = {
          test = "fastapi-helloworld"
        }
        replicas = 1
        selector = {
          match_labels = {
            test = "fastapi-helloworld"
          }
        }
        template = {

          metadata = {
            labels = {
              test = "fastapi-helloworld"
            }
          }
          spec = {
            volume = [
              {
              name = "app-data"
              config_map = {
                name = "data-for-app"
              }
              }
            ]
            container = [
              {
                # image = "680688655542.dkr.ecr.us-west-2.amazonaws.com/fastapi-helloworld-project"
                image = "489994096722.dkr.ecr.us-west-2.amazonaws.com/fastapi-helloworld-project:latest"
                name  = "fastapi-helloworld"

                ports = [
                  {
                    container_port = 80
                    name = "http"
                  }
                ]

                volume_mounts = [
                  {
                    name = "app-data"
                    mount_path = "/etc/data123"
                  }
                ]
                resources = {
                  limits = {
                    cpu    = "100"
                    memory = "100Mi"
                  }
                  requests = {
                    cpu    = "50m"
                    memory = "25Mi"
                  }
                }
                # liveness_probe = {
                #   http_get = {
                #     path = "/"
                #     port = "80"
                #   }
                #   initial_delay_seconds = 5
                #   period_seconds        = 3
                # }
              },
              # {
              #   image = "redis"
              #   name  = "fastapi-helloworld1"

              #   resources = {
              #     limits = {
              #       cpu    = "0.25"
              #       memory = "256Mi"
              #     }
              #     requests = {
              #       cpu    = "125m"
              #       memory = "50Mi"
              #     }
              #   }

              # }



            ]
          }

        }
      }

      fastapi-helloworld-1 = {

        labels = {
          test = "fastapi-helloworld-1"
        }
        replicas = 1
        selector = {
          match_labels = {
            test = "fastapi-helloworld-1"
            }
        }
        template = {

          metadata = {
            labels = {
              test = "fastapi-helloworld-1"
            }
          }
          spec = {

          container = [
            {
              image = "redis"
              name  = "fastapi-helloworld"

              resources = {
                limits = {
                  cpu    = "0.125"
                  memory = "50Mi"
                }
                requests = {
                  cpu    = "100m"
                  memory = "50Mi"
                }
              }
              # liveness_probe = {
              #   http_get = {
              #     path = "/"
              #     port = "80"
              #   }
              #   initial_delay_seconds = 5
              #   period_seconds = 3
              # }
            }
          ]
          }
        }
      }
    }
  }

  #### Project 2
  
  hello-world-2 = {

      services = {

        # fastapi_helloworld-2 = {

        #   selector = {
        #     test = "fastapi-helloworld"
        #   }

        #   port = [
        #     {
        #       port = 80
        #       target_port = 80
        #     }
        #   ]

        #   type = "LoadBalancer"

        # }

      }

      Deployments = {

        fastapi-helloworld-2 = {

          labels = {
            test = "fastapi-helloworld-2"
          }
          replicas = 1
          selector = {
            match_labels = {
              test = "fastapi-helloworld-2"
              }
          }
          template = {

            metadata = {
              labels = {
                test = "fastapi-helloworld-2"
              }
            }
            spec = {

            container = [
              {
                image = "489994096722.dkr.ecr.us-west-2.amazonaws.com/fastapi-helloworld-project:latest"
                name  = "fastapi-helloworld"

                resources = {
                  limits = {
                    cpu    = "0.1"
                    memory = "100Mi"
                  }
                  requests = {
                    cpu    = "50m"
                    memory = "50Mi"
                  }
                }
                # liveness_probe = {
                #   http_get = {
                #     path = "/"
                #     port = "80"
                #   }
                #   initial_delay_seconds = 5
                #   period_seconds = 3
                # }
              }
            ]
            }
          }
        }
      }
    }
}






