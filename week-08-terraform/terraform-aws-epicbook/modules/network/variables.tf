variable "name_prefix" {
  type = string
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

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to reach the EC2 instance over SSH"
  type        = string
}
