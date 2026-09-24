output "web_instance_ids" {
  description = "Web tier instance IDs, keyed [a, b]."
  value       = { for k, v in aws_instance.web : k => v.id }
}

output "web_private_ips" {
  description = "Web tier private IP addresses, keyed [a, b]."
  value       = { for k, v in aws_instance.web : k => v.private_ip }
}

output "web_public_ips" {
  description = "Web tier public IP addresses, keyed [a, b]."
  value       = { for k, v in aws_instance.web : k => v.public_ip }
}

output "app_instance_ids" {
  description = "Application tier instance IDs, keyed [a, b]."
  value       = { for k, v in aws_instance.app : k => v.id }
}

output "app_private_ips" {
  description = "Application tier private IP addresses, keyed [a, b]."
  value       = { for k, v in aws_instance.app : k => v.private_ip }
}
