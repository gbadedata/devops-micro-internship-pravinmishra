terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.account_id]

  default_tags {
    tags = {
      Project     = "book-review-app"
      Owner       = "oluwagbade-odimayo"
      Environment = "capstone"
      ManagedBy   = "terraform"
    }
  }
}
