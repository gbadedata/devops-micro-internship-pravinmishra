output "alb_public_sg_id" {
  description = "ID of the public ALB security group."
  value       = aws_security_group.alb_public.id
}

output "web_sg_id" {
  description = "ID of the web tier security group."
  value       = aws_security_group.web.id
}

output "alb_internal_sg_id" {
  description = "ID of the internal ALB security group."
  value       = aws_security_group.alb_internal.id
}

output "app_sg_id" {
  description = "ID of the application tier security group."
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "ID of the database tier security group."
  value       = aws_security_group.db.id
}

output "web_instance_profile_name" {
  description = "Name of the IAM instance profile for the web tier."
  value       = aws_iam_instance_profile.web.name
}

output "app_instance_profile_name" {
  description = "Name of the IAM instance profile for the app tier."
  value       = aws_iam_instance_profile.app.name
}

output "db_password_parameter_name" {
  description = "Name of the SSM SecureString parameter holding the DB password."
  value       = aws_ssm_parameter.db_password.name
}

output "jwt_secret_parameter_name" {
  description = "Name of the SSM SecureString parameter holding the JWT secret."
  value       = aws_ssm_parameter.jwt_secret.name
}
