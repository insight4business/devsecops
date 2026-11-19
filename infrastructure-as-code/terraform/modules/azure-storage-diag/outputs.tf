output "storage_account_id" {
  description = "Storage account ID, to use as destination in diagnostic settings."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Generated storage account name (prefix plus random suffix)."
  value       = azurerm_storage_account.this.name
}
