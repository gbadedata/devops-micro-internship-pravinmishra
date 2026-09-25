output "app_public_ip" {
  description = "Public IP of the EpicBook app server"
  value       = aws_instance.app.public_ip
}

output "app_url" {
  description = "EpicBook URL through Nginx"
  value       = "http://${aws_instance.app.public_ip}"
}

output "db_endpoint" {
  description = "RDS hostname (private; reachable only from the app server)"
  value       = aws_db_instance.mysql.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mysql.db_name
}

output "db_username" {
  description = "Database user"
  value       = aws_db_instance.mysql.username
}

# The database password is deliberately NOT an output.
