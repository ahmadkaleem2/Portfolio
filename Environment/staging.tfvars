AWS_REGION  = "us-west-1"
identifier = "Ahmad"
vpcs = {
  vpc-dev = {
    enabled = false
    VPC_CIDR_BLOCK     = "10.0.0.0/16"
    public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

    private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

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
    enabled = true
    VPC_CIDR_BLOCK     = "10.0.0.0/16"
    public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

    private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

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
      DB_NAME = "wordpress"
    }

    script_path = "./scripts/install-mysql.sh"

    instance_type = "t2.micro"

    

  }

}

asg = {

  key_pair_name = "ahmad-terraform-key"

  user_data_path = "./scripts/install-wordpress.sh"

  instance_type = "t2.micro"
  min_capacity = 1
  max_capacity = 4
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

      port = 80
      protocol = "HTTP"
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
        port = 80
        protocol = "HTTP"
        health_check_path = "/"
        health_check_threshold = 2
        unhealthy_threshold = 5
        timeout = 45
        interval = 60
        matcher = "200-302"
      }
    }

  
}


