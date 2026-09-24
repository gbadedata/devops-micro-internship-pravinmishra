output "primary_address" {
  description = "Hostname of the primary RDS instance."
  value       = aws_db_instance.primary.address
}

output "port" {
  description = "Port the RDS instances accept connections on."
  value       = aws_db_instance.primary.port
}

output "replica_address" {
  description = "Hostname of the read replica RDS instance."
  value       = aws_db_instance.replica.address
}

output "db_name" {
  description = "Name of the database created on the primary instance."
  value       = aws_db_instance.primary.db_name
}
