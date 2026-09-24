output "ec2_public_ip" {
  description = "Public IP of the EpicBook EC2 instance"
  value       = module.ec2.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EpicBook EC2 instance"
  value       = module.ec2.instance_id
}

output "rds_endpoint" {
  description = "Hostname of the private RDS MySQL instance"
  value       = module.rds.endpoint
}
