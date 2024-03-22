# data "aws_acm_certificate" "domain_certificate" {
#   domain   = var.domain
#   statuses = ["ISSUED"]
# }