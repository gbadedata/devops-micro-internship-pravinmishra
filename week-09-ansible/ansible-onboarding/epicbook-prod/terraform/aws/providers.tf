# Terraform and AWS provider for EpicBook (Oluwagbade Odimayo).
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
  region = var.region

  # Guardrail: refuse to run against any AWS account except the intended one.
  # account_id lives in the git-ignored local.auto.tfvars.
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = {
      Project   = "dmi-week9-epicbook-prod"
      Owner     = "Oluwagbade Odimayo"
      ManagedBy = "terraform"
    }
  }
}
