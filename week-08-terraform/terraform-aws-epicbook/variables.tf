variable "region" {
  description = "AWS region for all resources"
  type        = string
}

variable "account_id" {
  description = "The only AWS account this configuration may run in (set in git-ignored local.auto.tfvars)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names and tags"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "db_subnet_a_cidr" {
  type = string
}

variable "db_subnet_b_cidr" {
  type = string
}

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form for SSH (set in git-ignored local.auto.tfvars)"
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be a valid CIDR such as 203.0.113.10/32."
  }
}

variable "instance_type" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password (supplied via TF_VAR_db_password, never stored in files)"
  type        = string
  sensitive   = true
}
