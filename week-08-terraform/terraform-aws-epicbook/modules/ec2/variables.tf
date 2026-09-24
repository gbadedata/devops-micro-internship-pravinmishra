variable "name_prefix" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_key_path" {
  type = string
}

variable "subnet_id" {
  description = "Public subnet from the network module"
  type        = string
}

variable "security_group_id" {
  description = "EC2 security group from the network module"
  type        = string
}
