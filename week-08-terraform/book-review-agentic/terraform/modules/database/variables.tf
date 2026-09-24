variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
}

variable "db_subnet_ids" {
  description = "Database tier subnet IDs, ordered [a, b]."
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group ID for the database tier."
  type        = string
}

variable "db_username" {
  description = "MySQL master username for the primary RDS instance. Not a secret."
  type        = string
}

variable "db_password" {
  description = "MySQL master password, written only to password_wo on the primary instance."
  type        = string
  sensitive   = true
  ephemeral   = true
}
