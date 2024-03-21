
resource "aws_lb" "load_balancer" {
  name = "${terraform.workspace}-${var.identifier}-testing-site"
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [ var.vpc_security_groups["alb_security_group"].id ]
  subnets            = slice([for i in var.public_subnets: i.id],0,length(var.region_azs))



  enable_deletion_protection = false


  # dynamic "listener" {
  #   for_each = var.listeners

  #   content {
  #     port = listener.value.port
  #     protocol = listener.value.protocol

  #     dynamic "default_action" {
  #       for_each = listener.value.target_group_name

  #       content {
  #         type             = "forward"
  #         target_group_arn = aws_lb_target_group.load_balancer_tg[listener.value.target_group_name].arn
  #       }
  #     }


  #   }
  # }



  tags = {
    Name = "${terraform.workspace}-${var.identifier}-testing_site"
  }
}



resource "aws_lb_target_group" "load_balancer_tg" {

  for_each = var.target_groups

  name     = "${terraform.workspace}-${var.identifier}-${each.key}"
  port     = each.value.port
  protocol = each.value.protocol
  # protocol = "HTTP"
  vpc_id   = var.vpc.id
  # target_type = "instance"

  health_check {
    path = each.value.health_check_path
    healthy_threshold = each.value.health_check_threshold
    unhealthy_threshold = each.value.unhealthy_threshold
    timeout = each.value.timeout
    interval = each.value.interval
    matcher = each.value.matcher
  }
}


resource "aws_lb_listener" "load_balancer_listener_HTTP" {

  for_each = var.listeners

  load_balancer_arn = aws_lb.load_balancer.arn
  port              = each.value.port
  protocol          = each.value.protocol

  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_tg[each.value.target_group_name].arn
  }
  
}




































# resource "aws_lb" "load_balancer" {
#   name = "${terraform.workspace}-${var.identifier}-testing-site"
#   internal           = false
#   load_balancer_type = var.lb_type
#   security_groups    = [ var.vpc_security_groups["alb_security_group"].id ]
#   subnets            = slice([for i in var.public_subnets: i.id],0,length(var.region_azs))



#   enable_deletion_protection = false


  



#   tags = {
#     Name = "${terraform.workspace}-${var.identifier}-testing_site"
#   }
# }



# resource "aws_lb_target_group" "load_balancer_tg" {
#   name     = "${terraform.workspace}-${var.identifier}-alb-tg"
#   port     = 80
#   protocol = var.protocol_types_for_elb_type_for_http[ var.lb_type ]
#   # protocol = "HTTP"
#   vpc_id   = var.vpc.id
#   # target_type = "instance"

#   health_check {
#     path = "/"
#     healthy_threshold = 5
#     unhealthy_threshold = 2
#     timeout = 2
#     interval = 5
#     matcher = "200-302"
#   }
# }


# resource "aws_lb_listener" "load_balancer_listener_HTTP" {
#   load_balancer_arn = aws_lb.load_balancer.arn
#   port              = 80
#   # protocol          = "HTTP"
#   protocol          = var.protocol_types_for_elb_type_for_http[ var.lb_type ]

  
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.load_balancer_tg.arn
#   }
  
# }

# resource "aws_lb_listener" "load_balancer_listener_HTTPS" {

#   count = data.aws_acm_certificate.domain_certificate.arn != null ? 1 : 0 

#   load_balancer_arn = aws_lb.load_balancer.arn
#   port              = 443
#   protocol          = var.protocol_types_for_elb_type_for_https[ var.lb_type ]

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.load_balancer_tg.arn
#   }

#   certificate_arn = data.aws_acm_certificate.domain_certificate.arn
# }


