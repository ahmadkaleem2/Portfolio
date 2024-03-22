
resource "aws_autoscaling_group" "asg_launch_template" {
  name                   = "${terraform.workspace}-${var.identifier}-wordpress-asg-policy"
  max_size           = var.max_capacity
  min_size           = var.min_capacity
  
  vpc_zone_identifier = var.use_public_subnet_for_asg ? [ for i in var.public_subnets : i.id] : [ for i in var.private_subnets : i.id]
  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  target_group_arns = [ var.load_balancer_tg["wordpress-tg"].arn ]
  depends_on = [ aws_launch_template.wordpress, var.mysql_instance, var.load_balancer ]
  
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


resource "aws_security_group" "webserver_security_group" {

  name        = "ec2-sg"
  description = "Allow HTTP inbound traffic and all outbound traffic"
  vpc_id      = var.vpc.id

  ingress {
            from_port   = 80
            protocol    = "tcp"
            to_port     = 80
            security_groups = [ var.vpc_security_groups["alb_security_group"].id ]
          }
  ingress {
            from_port   = 22
            protocol    = "tcp"
            to_port     = 22
            security_groups = [ var.vpc_security_groups["bastion_security_group"].id ]
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
  key_name = var.key_pair_name

  
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
    associate_public_ip_address = var.use_public_subnet_for_asg 
    
    security_groups = [ aws_security_group.webserver_security_group.id ]
    subnet_id = var.public_subnets[0].id
  }

  placement {
  
    availability_zone = var.use_public_subnet_for_asg ? var.public_subnets[0].availability_zone : var.private_subnets[0].availability_zone
  

  }





  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${terraform.workspace}-${var.identifier}-ec2-instance"
    }
  }

  user_data = base64encode("${data.cloudinit_config.cloudinit_script.rendered}")

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

