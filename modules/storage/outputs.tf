output "primary_host" {
  value = azurerm_storage_account.this.primary_blob_host
}

output "container_name" {
  value = azurerm_storage_container.this.name
}
