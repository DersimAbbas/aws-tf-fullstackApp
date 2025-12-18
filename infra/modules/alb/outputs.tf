output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "prod_listener_arn" {
  value = aws_lb_listener.prod.arn
}

output "test_listener_arn" {
  value = length(aws_lb_listener.test) > 0 ? aws_lb_listener.test[0].arn : null
}

output "tg_blue_arn" {
  value = aws_lb_target_group.blue.arn
}

output "tg_green_arn" {
  value = aws_lb_target_group.green.arn
}

output "tg_blue_name" {
  value = aws_lb_target_group.blue.name
}

output "tg_green_name" {
  value = aws_lb_target_group.green.name
}
