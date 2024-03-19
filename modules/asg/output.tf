
output "user_data_lt" {
    value = aws_launch_template.wordpress.user_data
}

output "webserver_sg" {
    value = aws_security_group.ec2_sg
}