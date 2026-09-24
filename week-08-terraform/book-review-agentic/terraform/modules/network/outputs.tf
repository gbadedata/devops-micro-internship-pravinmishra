output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.main.cidr_block
}

output "web_subnet_ids" {
  description = "Web tier subnet IDs, ordered [a, b]."
  value       = [aws_subnet.web["a"].id, aws_subnet.web["b"].id]
}

output "app_subnet_ids" {
  description = "Application tier subnet IDs, ordered [a, b]."
  value       = [aws_subnet.app["a"].id, aws_subnet.app["b"].id]
}

output "db_subnet_ids" {
  description = "Database tier subnet IDs, ordered [a, b]."
  value       = [aws_subnet.db["a"].id, aws_subnet.db["b"].id]
}
