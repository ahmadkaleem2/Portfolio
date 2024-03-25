
resource "aws_lb" "load_balancer" {
  name = "${terraform.workspace}-${var.identifier}-testing-site"
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [ var.vpc_security_groups["alb_security_group"].id ]
  subnets            = slice([for i in var.public_subnets: i.id],0,length(var.region_azs))

  enable_deletion_protection = false


  tags = {
    Name = "${terraform.workspace}-${var.identifier}-testing_site"
  }
}



resource "aws_lb_target_group" "load_balancer_tg" {

  for_each = var.target_groups

  name     = "${terraform.workspace}-${var.identifier}-${each.key}"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = var.vpc.id


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

  certificate_arn = lookup(each.value,"certificate_arn",null)
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_tg[each.value.target_group_name].arn
  }
  
}















