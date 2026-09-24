variable "vpc_id" {
  description = "ID of the VPC to create security groups in."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
}

variable "my_ip_cidr" {
  description = "Owner's IP address in CIDR notation, used for the web tier SSH rule."
  type        = string
}

variable "db_password" {
  description = "MySQL master password, stored as an SSM SecureString parameter."
  type        = string
  sensitive   = true
  ephemeral   = true
}

variable "jwt_secret" {
  description = "Backend JWT signing secret, stored as an SSM SecureString parameter."
  type        = string
  sensitive   = true
  ephemeral   = true
}
