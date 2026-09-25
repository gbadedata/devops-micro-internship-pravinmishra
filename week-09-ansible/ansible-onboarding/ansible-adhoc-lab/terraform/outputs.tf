output "public_ips" {
  description = "Public IP of every VM, keyed by hostname (the prefix is the inventory role)"
  value       = { for name, vm in aws_instance.server : name => vm.public_ip }
}

output "servers_by_role" {
  description = "Hostnames grouped by Ansible inventory role"
  value = {
    for role in distinct([for s in values(var.servers) : s.role]) :
    role => sort([for name, s in var.servers : name if s.role == role])
  }
}

output "ssh_user" {
  description = "Default login user on the Ubuntu AMI"
  value       = "ubuntu"
}
