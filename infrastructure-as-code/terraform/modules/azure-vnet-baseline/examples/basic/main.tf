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

  # azurerm 4.x requires the subscription. Prefer the ARM_SUBSCRIPTION_ID
  # environment variable in pipelines; this placeholder is only for the example.
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

module "network" {
  source = "../.."

  name     = "contoso-dev"
  location = "eastus2"

  # Required, no default. Example: the range of a corporate VPN.
  admin_source_cidrs = ["203.0.113.0/24"]

  enable_nat_gateway = true

  tags = {
    Project     = "contoso-app"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "platform@example.com"
  }
}

output "subnet_id" {
  value = module.network.subnet_id
}
