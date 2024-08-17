output "alb_dns" {
  value = "http://${aws_lb.front_end.dns_name}"
}
