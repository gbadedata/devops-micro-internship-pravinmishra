variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "account_id" {
  description = "The only AWS account this configuration may touch (set in git-ignored local.auto.tfvars)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for every resource name"
  type        = string
  default     = "epicbook-prod"
}

variable "controller_cidr" {
  description = "Public IP of the Ansible controller as a /32. Supplied via TF_VAR_controller_cidr, never committed."
  type        = string

  validation {
    condition     = can(cidrhost(var.controller_cidr, 0)) && endswith(var.controller_cidr, "/32")
    error_message = "controller_cidr must be a single IPv4 address in /32 form, for example 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 instance type for the application server"
  type        = string
  default     = "t3.micro"
}

variable "public_key_path" {
  description = "Controller SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name. Must be bookstore: EpicBook's schema file hardcodes it."
  type        = string
  default     = "bookstore"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "epicbook_admin"
}

variable "db_password" {
  description = "RDS master password. Supplied via TF_VAR_db_password, never committed or output."
  type        = string
  sensitive   = true
}
