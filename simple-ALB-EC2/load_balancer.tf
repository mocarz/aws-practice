resource "aws_lb" "front_end" {
  name               = "main-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [for subnet in aws_subnet.public_subnets : subnet.id]

  depends_on = [aws_instance.instances]
}

resource "aws_lb_target_group" "front_end" {
  name     = "front-end-a-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  depends_on = [aws_lb.front_end]
}

resource "aws_lb_target_group_attachment" "tg_attachments" {
  count = length(var.private_subnet_cidrs)
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = element(aws_instance.instances, count.index).id
  port = 80

  depends_on = [aws_lb_target_group.front_end]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }

  depends_on = [aws_lb.front_end]
}


resource "aws_security_group" "alb_sg" {
  name = "ALB SG"
  vpc_id = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_allow_80_in_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80

  depends_on = [aws_security_group.alb_sg]
}


resource "aws_vpc_security_group_egress_rule" "alb_allow_all_out_traffic_ipv4" {
  security_group_id = aws_security_group.alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80

  depends_on = [aws_security_group.alb_sg]
}

