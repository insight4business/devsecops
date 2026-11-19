terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}

  # azurerm 4.x requires the subscription. Prefer ARM_SUBSCRIPTION_ID in pipelines.
  subscription_id = "00000000-0000-0000-0000-000000000000"
}

resource "azurerm_resource_group" "logs" {
  name     = "rg-contoso-logs"
  location = "eastus2"
}

module "diag_storage" {
  source = "../.."

  name_prefix         = "contosodiag"
  resource_group_name = azurerm_resource_group.logs.name
  location            = azurerm_resource_group.logs.location
  retention_days      = 90

  tags = {
    Project     = "contoso-app"
    Environment = "dev"
    ManagedBy   = "terraform"
    Owner       = "platform@example.com"
  }
}

# Send a resource's logs to the account (replace the target resource ID).
# resource "azurerm_monitor_diagnostic_setting" "example" {
#   name               = "to-storage"
#   target_resource_id = "<RESOURCE_ID>"
#   storage_account_id = module.diag_storage.storage_account_id
#
#   enabled_log {
#     category_group = "allLogs"
#   }
# }
