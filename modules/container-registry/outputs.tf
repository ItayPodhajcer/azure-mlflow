output "registry_id" {
  value = azurerm_container_registry.this.id
}

output "registry_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "image_name" {
  value = local.image_name
}
