resource "aws_lb" "load" {
  name = var.loadbalancer
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow.id]
  subnets = [for subnet in aws_subnet.cloud : subnet.id]
}

resource "aws_lb_target_group" "target" {
  name = var.targetgroup
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.net.id
  health_check {
  port = 80
  protocol = "HTTP"
  path = "/"
  matcher = "200-299"
}
}

resource "aws_lb_target_group_attachment" "main" {
  for_each = aws_instance.ubuntu
  target_group_arn = aws_lb_target_group.target.arn
  target_id = each.value.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load.arn
  port = 80
  protocol = "HTTP"
  default_action {
  type = "forward"
  target_group_arn = aws_lb_target_group.target.arn
}

}
