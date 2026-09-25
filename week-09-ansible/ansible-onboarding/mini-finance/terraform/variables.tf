variable "location" {
  description = "Azure region (UK West worked reliably for this subscription in earlier weeks)"
  type        = string
  default     = "ukwest"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Linux admin user created on the VM"
  type        = string
  default     = "azureuser"
}

variable "public_key_path" {
  description = "SSH public key uploaded to the VM (RSA, proven with this subscription in Week 8)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "controller_cidr" {
  description = "Public IP of the Ansible controller as a /32. Supplied via TF_VAR_controller_cidr, never committed."
  type        = string

  validation {
    condition     = can(cidrhost(var.controller_cidr, 0)) && endswith(var.controller_cidr, "/32")
    error_message = "controller_cidr must be a single IPv4 address in /32 form, for example 203.0.113.10/32."
  }
}
