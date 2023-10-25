resource "aws_alb" "my_alb" {
    name = "aws_web_loadbalancer"
    load_balancer_type = "application"
    security_groups = [aws_security_group.app_security_group.id]
    subnets = aws_subnet
  
}