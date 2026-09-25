output "public_ip" {
  description = "Public IP of the Mini Finance VM"
  value       = azurerm_public_ip.pip.ip_address
}

output "admin_username" {
  description = "SSH user for Ansible"
  value       = var.admin_username
}

output "resource_group" {
  description = "Resource group holding every Mini Finance resource"
  value       = azurerm_resource_group.rg.name
}
