output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "db_subnet_ids" {
  description = "Private DB subnets in two different Availability Zones"
  value       = [aws_subnet.db_a.id, aws_subnet.db_b.id]
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
