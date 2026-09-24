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
}

variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
  default     = "oluwagbade-bookreview"
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
