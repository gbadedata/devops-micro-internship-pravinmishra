variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into, passed to the app tier's SSM CLI calls."
  type        = string
}

variable "web_subnet_ids" {
  description = "Web tier subnet IDs, ordered [a, b]."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Application tier subnet IDs, ordered [a, b]."
  type        = list(string)
}

variable "web_sg_id" {
  description = "Security group ID for the web tier."
  type        = string
}

variable "app_sg_id" {
  description = "Security group ID for the application tier."
  type        = string
}

variable "web_instance_profile_name" {
  description = "IAM instance profile name for the web tier."
  type        = string
}

variable "app_instance_profile_name" {
  description = "IAM instance profile name for the application tier."
  type        = string
}

variable "web_tg_arn" {
  description = "ARN of the web tier target group."
  type        = string
}

variable "app_tg_arn" {
  description = "ARN of the application tier target group."
  type        = string
}

variable "internal_alb_dns_name" {
  description = "DNS name of the internal ALB, used by web tier nginx to proxy /api/."
  type        = string
}

variable "public_alb_dns_name" {
  description = "DNS name of the public ALB, used to build ALLOWED_ORIGINS for the backend."
  type        = string
}

variable "db_primary_address" {
  description = "Hostname of the primary RDS instance."
  type        = string
}

variable "db_name" {
  description = "Name of the database created on the primary RDS instance."
  type        = string
}

variable "db_username" {
  description = "MySQL master username. Not a secret."
  type        = string
}

variable "db_password_parameter_name" {
  description = "Name (not value) of the SSM SecureString parameter holding the DB password."
  type        = string
}

variable "jwt_secret_parameter_name" {
  description = "Name (not value) of the SSM SecureString parameter holding the JWT secret."
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key registered for web-tier access. Only the public key is ever read."
  type        = string
}

variable "repo_url" {
  description = "Git URL of the Book Review App repository."
  type        = string
}

variable "repo_ref" {
  description = "Git ref (commit SHA recommended) to deploy."
  type        = string
}
