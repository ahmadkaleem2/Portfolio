
output "user_data_lt" {
    value = aws_launch_template.wordpress.user_data
}

output "webserver_security_group" {
    value = aws_security_group.webserver_security_group
}