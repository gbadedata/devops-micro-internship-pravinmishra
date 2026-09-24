variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "eu-west-2"
}

variable "account_id" {
  description = "AWS account ID this configuration is allowed to operate against. Set in the git-ignored local.auto.tfvars."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "my_ip_cidr" {
  description = "Owner's IP address in CIDR notation, used for SSH security-group rules in a later phase. Set in the git-ignored local.auto.tfvars."
  type        = string

  validation {
    condition     = can(cidrhost(var.my_ip_cidr, 0))
    error_message = "my_ip_cidr must be a valid IPv4 CIDR block."
  }

  validation {
    condition     = endswith(var.my_ip_cidr, "/32")
    error_message = "my_ip_cidr must be a single IPv4 address in /32 form."
  }
}

variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
  default     = "oluwagbade-bookreview"

  # ALB and target group names are limited to 32 characters and the longest
  # suffix appended is 8 ("-alb-pub"), so the prefix is capped at 21.
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,20}$", var.name_prefix))
    error_message = "name_prefix must be 1-21 characters of lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "azs" {
  description = "Availability zones to place the tiered subnets in, ordered [a, b]."
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]

  validation {
    condition     = length(var.azs) == 2 && length(distinct(var.azs)) == 2
    error_message = "azs must contain exactly 2 distinct availability zones."
  }
}

variable "db_password" {
  description = "MySQL master password, supplied via TF_VAR_db_password. Never given a default."
  type        = string
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = length(var.db_password) >= 12
    error_message = "db_password must be at least 12 characters long."
  }

  validation {
    condition     = !can(regex("[/@\" ]", var.db_password))
    error_message = "db_password must not contain /, @, \" or spaces (RDS restriction)."
  }
}

variable "db_username" {
  description = "MySQL master username for the primary RDS instance. Not a secret."
  type        = string
  default     = "bookreview_app"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,15}$", var.db_username))
    error_message = "db_username must start with a letter and be 1-16 alphanumeric/underscore characters (RDS MySQL master username limit)."
  }
}

variable "public_key_path" {
  description = "Path to the SSH public key registered for web-tier access. Only the public key is ever read."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "repo_url" {
  description = "Git URL of the Book Review App repository."
  type        = string
  default     = "https://github.com/pravinmishraaws/book-review-app.git"
}

variable "repo_ref" {
  description = "Git ref (commit SHA recommended) to deploy."
  type        = string
  default     = "84280063bea7ccd5144dafa2b969ec4e2e69ffbb"
}

variable "jwt_secret" {
  description = "Backend JWT signing secret, supplied via TF_VAR_jwt_secret. Never given a default."
  type        = string
  sensitive   = true
  ephemeral   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must be at least 32 characters long."
  }
}
