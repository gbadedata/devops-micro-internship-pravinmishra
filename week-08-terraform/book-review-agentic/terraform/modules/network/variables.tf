variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "name_prefix" {
  description = "Prefix applied to resource Name tags for consistent naming."
  type        = string
}

variable "azs" {
  description = "Availability zones to place the tiered subnets in, ordered [a, b]."
  type        = list(string)

  validation {
    condition     = length(var.azs) == 2 && length(distinct(var.azs)) == 2
    error_message = "azs must contain exactly 2 distinct availability zones."
  }
}
