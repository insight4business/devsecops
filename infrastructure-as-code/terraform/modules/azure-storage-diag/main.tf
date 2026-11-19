# Storage account for diagnostic logs.
# - TLS 1.2 minimum, HTTPS only, no public blob access.
# - Firewall default Deny; Azure Monitor and other trusted services bypass it.
# - Random suffix keeps the globally unique name stable per deployment.

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_storage_account" "this" {
  name                = "${var.name_prefix}${random_string.suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.location

  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = true # reachable only through the firewall rules below

  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_days
    }
  }

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# Delete old log blobs to control cost and limit data kept.
resource "azurerm_storage_management_policy" "retention" {
  storage_account_id = azurerm_storage_account.this.id

  rule {
    name    = "delete-old-logs"
    enabled = true

    filters {
      blob_types = ["blockBlob", "appendBlob"]
    }

    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = var.retention_days
      }
    }
  }
}
