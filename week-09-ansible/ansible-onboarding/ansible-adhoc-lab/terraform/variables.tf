variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "EC2 instance type for every managed VM"
  type        = string
  default     = "t3.micro"
}

variable "controller_cidr" {
  description = "Public IP of the Ansible controller as a /32. Supplied at runtime via TF_VAR_controller_cidr, never committed."
  type        = string

  validation {
    condition     = can(cidrhost(var.controller_cidr, 0)) && endswith(var.controller_cidr, "/32")
    error_message = "controller_cidr must be a single IPv4 address in /32 form, for example 203.0.113.10/32."
  }
}

variable "public_key_path" {
  description = "Path to the controller's ED25519 public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "servers" {
  description = "Managed VMs keyed by hostname, each with its Ansible inventory role"
  type = map(object({
    role = string
  }))
  default = {
    web1 = { role = "web" }
    web2 = { role = "web" }
    app1 = { role = "app" }
    db1  = { role = "db" }
  }

  validation {
    condition     = alltrue([for s in values(var.servers) : contains(["web", "app", "db"], s.role)])
    error_message = "Each server role must be web, app or db."
  }
}
