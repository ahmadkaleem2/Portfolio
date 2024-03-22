

variable "identifier" {
  
}

variable "region_azs" {
  
}

variable "min_capacity" {
  
}

variable "max_capacity" {
  
}

variable "public_subnets" {

}

variable "private_subnets" {
    
}


variable "ami" {
  
}

variable "instance_type" {
  
}

variable "vpc_security_groups" {
  
}

variable "vpc" {
  
}

variable "key_pair_name" {

}


variable "tags_all" {
  
}

variable "mysql_instance" {
  
}

variable "step_adjustment_scale_down" {
  
}

variable "step_adjustment_scale_up" {
  
}

variable "cpu_alarm_threshold_low" {
  default = 30
}

variable "cpu_alarm_threshold_high" {
  default = 65
}

variable "load_balancer" {
  
}

variable "load_balancer_tg" {
  
}

variable "use_public_subnet_for_asg" {

}

variable "asg_script_path" {
  
}

variable "asg_script_args" {
  
}