output "app_url" {
  description = "Public URL of the Book Review App (public ALB, HTTP only)."
  value       = "http://${module.load_balancer.public_alb_dns_name}"
}
