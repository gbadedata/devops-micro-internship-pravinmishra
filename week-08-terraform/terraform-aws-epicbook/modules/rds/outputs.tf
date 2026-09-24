# Endpoint only. The password is deliberately never output.
output "endpoint" {
  description = "RDS hostname (without port)"
  value       = aws_db_instance.mysql.address
}

output "port" {
  value = aws_db_instance.mysql.port
}
