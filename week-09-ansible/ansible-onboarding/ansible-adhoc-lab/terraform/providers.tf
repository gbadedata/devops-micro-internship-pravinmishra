# Terraform and AWS provider requirements for the ansible-adhoc-lab (Oluwagbade Odimayo).
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "dmi-week9-ansible-adhoc-lab"
      Owner     = "Oluwagbade Odimayo"
      ManagedBy = "terraform"
    }
  }
}
