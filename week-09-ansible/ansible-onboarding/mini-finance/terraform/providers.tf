# Terraform and AzureRM provider for the Mini Finance deployment (Oluwagbade Odimayo).
# subscription_id comes from the ARM_SUBSCRIPTION_ID environment variable, never from a file.
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}
