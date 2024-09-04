variable "tags_all" {

}

variable "identifier" {

}

variable "subnets" {

}

locals {
  subnet_ids = [for subnet in var.subnets : subnet.id]
}

variable "eks_configuration" {

}

variable "vpc_id" {
  
}