

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

variable "sgs" {
  
}

variable "vpc" {
  
}

variable "key_pair" {

}
variable "DB_SETTINGS" {
  
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