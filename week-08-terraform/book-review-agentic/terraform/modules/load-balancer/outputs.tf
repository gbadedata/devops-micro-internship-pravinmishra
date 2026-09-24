output "public_alb_dns_name" {
  description = "DNS name of the public (internet-facing) ALB."
  value       = aws_lb.public.dns_name
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal ALB."
  value       = aws_lb.internal.dns_name
}

output "web_tg_arn" {
  description = "ARN of the web tier target group."
  value       = aws_lb_target_group.web.arn
}

output "app_tg_arn" {
  description = "ARN of the application tier target group."
  value       = aws_lb_target_group.app.arn
}
