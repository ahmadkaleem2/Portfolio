

resource "aws_lb" "load_balancer" {
  name = "${terraform.workspace}-${var.identifier}-testing-site"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sgs["alb_sg"].id]
  subnets            = slice([for i in var.public_subnets: i.id],0,length(var.region_azs))



  enable_deletion_protection = false


  tags = {
    Name = "${terraform.workspace}-${var.identifier}-testing_site"
  }
}



resource "aws_lb_target_group" "load_balancer_tg" {
  name     = "${terraform.workspace}-${var.identifier}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc.id
  target_type = "instance"

  health_check {
    path = "/"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 2
    interval = 5
    matcher = "200-302"
  }
}


resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_tg.arn
  }
}


resource "aws_autoscaling_group" "asg_launch_template" {
  name                   = "${terraform.workspace}-${var.identifier}-wordpress-asg-policy"
  # availability_zones = ["us-east-2b"]
  # desired_capacity   = var.desired_capacity
  max_size           = var.max_capacity
  min_size           = var.min_capacity
  # vpc_zone_identifier = [var.public_subnets[0].id, var.public_subnets[1].id, var.public_subnets[2].id]
  vpc_zone_identifier = [for i in var.private_subnets: i.id] # fix this
  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }
  # load_balancers = [aws_lb.test.id]
  target_group_arns = [aws_lb_target_group.load_balancer_tg.arn]
  depends_on = [ aws_launch_template.wordpress, var.mysql_instance, aws_lb.load_balancer ]
  
}

resource "aws_autoscaling_policy" "aws_asg_scale_up" {
  name                   = "${terraform.workspace}-${var.identifier}-wordpress-asg-policy"

  adjustment_type        = "ChangeInCapacity"

  autoscaling_group_name = aws_autoscaling_group.asg_launch_template.name
  policy_type = "StepScaling"
  metric_aggregation_type = "Average"
  enabled = true

  

  dynamic "step_adjustment" {
    for_each = var.step_adjustment_scale_up
    content {
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
    }
  }

  depends_on = [ aws_autoscaling_group.asg_launch_template ]
}


resource "aws_autoscaling_policy" "aws_asg_scale_down" {
  name                   = "${terraform.workspace}-${var.identifier}-wordpress-asg-policy-scale-down"

  adjustment_type        = "ChangeInCapacity"

  autoscaling_group_name = aws_autoscaling_group.asg_launch_template.name
  policy_type = "StepScaling"
  metric_aggregation_type = "Average"
  enabled = true

  

  dynamic "step_adjustment" {
    for_each = var.step_adjustment_scale_down
    content {
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
    }
  }

  depends_on = [ aws_autoscaling_group.asg_launch_template ]
}


resource "aws_security_group" "ec2_sg" {

  name        = "ec2-sg"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc.id

  ingress {
            from_port   = 80
            protocol    = "tcp"
            to_port     = 80
            security_groups = [ var.sgs["alb_sg"].id ]
          }
  ingress {
            from_port   = 22
            protocol    = "tcp"
            to_port     = 22
            security_groups = [ var.sgs["bastion_sg"].id ]
          }
  
  egress {
            from_port   = 0
            to_port     = 0
            protocol    = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          }



  tags = merge(var.tags_all, {
    Name = "${terraform.workspace}-${var.identifier}-ec2-sg"
  })
}


resource "aws_launch_template" "wordpress" {
  name = "${terraform.workspace}-${var.identifier}-launch-template"
  

#   key_name = aws_key_pair.mykeypair.key_name
  key_name = var.key_pair.key_name

  
  image_id = var.ami

  disable_api_stop        = false
  disable_api_termination = false

  ebs_optimized = false

  instance_type = var.instance_type

  instance_initiated_shutdown_behavior = "terminate"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  network_interfaces {
      
    associate_public_ip_address = false
    security_groups = [ aws_security_group.ec2_sg.id ]
    subnet_id = var.public_subnets[0].id
  }

  placement {
    # availability_zone = ["us-east-2b"]
    availability_zone = var.private_subnets[0].availability_zone
    # availability_zone = [for i in var.private_subnets : i.availability_zone]

  }





  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${terraform.workspace}-${var.identifier}-ec2-instance"
    }
  }

  user_data = base64encode("${data.cloudinit_config.install-wordpress.rendered}")

  depends_on = [ var.mysql_instance ]
}







resource "aws_cloudwatch_metric_alarm" "cpu_alarm_high" {
  alarm_name          = "${terraform.workspace}-${var.identifier}-cpu-alarm-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 240
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold_high
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_launch_template.name
  }

  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.aws_asg_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm_low" {
  alarm_name          = "${terraform.workspace}-${var.identifier}-cpu-alarm-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 240
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold_low
  alarm_description   = "This metric monitors CPU utilization."

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg_launch_template.name
  }

  alarm_actions       = [aws_autoscaling_policy.aws_asg_scale_down.arn]
}

