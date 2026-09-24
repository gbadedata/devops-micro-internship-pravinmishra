variable "vpc_id" {
  description = "ID of the VPC to create target groups in."
  type        = string
}

variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
}

variable "web_subnet_ids" {
  description = "Web tier subnet IDs, ordered [a, b], for the public ALB."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Application tier subnet IDs, ordered [a, b], for the internal ALB."
  type        = list(string)
}

variable "alb_public_sg_id" {
  description = "Security group ID for the public ALB."
  type        = string
}

variable "alb_internal_sg_id" {
  description = "Security group ID for the internal ALB."
  type        = string
}
