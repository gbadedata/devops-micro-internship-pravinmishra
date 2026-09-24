output "vpc_id" {
  description = "ID of the VPC created for the Book Review App."
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC created for the Book Review App."
  value       = module.network.vpc_cidr
}

output "web_subnet_ids" {
  description = "Web tier subnet IDs, ordered [a, b]."
  value       = module.network.web_subnet_ids
}

output "app_subnet_ids" {
  description = "Application tier subnet IDs, ordered [a, b]."
  value       = module.network.app_subnet_ids
}

output "db_subnet_ids" {
  description = "Database tier subnet IDs, ordered [a, b]."
  value       = module.network.db_subnet_ids
}

output "app_url" {
  description = "Public URL of the Book Review App (public ALB, HTTP only)."
  value       = "http://${module.load_balancer.public_alb_dns_name}"
}
