variable "name_prefix" {
  type = string
}

variable "db_subnet_ids" {
  description = "Private DB subnets from the network module"
  type        = list(string)
}

variable "security_group_id" {
  description = "RDS security group from the network module"
  type        = string
}

variable "instance_class" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}
