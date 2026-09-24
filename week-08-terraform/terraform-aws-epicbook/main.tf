# Assignment 4: EpicBook on AWS with Terraform modules and Amazon RDS for MySQL
# Author: Oluwagbade Odimayo

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  # Guardrail: refuse to run against any AWS account except the intended one
  allowed_account_ids = [var.account_id]
}

module "network" {
  source = "./modules/network"

  name_prefix        = var.name_prefix
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  db_subnet_a_cidr   = var.db_subnet_a_cidr
  db_subnet_b_cidr   = var.db_subnet_b_cidr
  ssh_allowed_cidr   = var.my_ip_cidr
}

module "ec2" {
  source = "./modules/ec2"

  name_prefix       = var.name_prefix
  instance_type     = var.instance_type
  public_key_path   = var.public_key_path
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.ec2_security_group_id
}

module "rds" {
  source = "./modules/rds"

  name_prefix       = var.name_prefix
  db_subnet_ids     = module.network.db_subnet_ids
  security_group_id = module.network.rds_security_group_id
  instance_class    = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
}
