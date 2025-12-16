output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "resources_subnet_id" {
  value = azurerm_subnet.resources.id
}

output "app_subnet_id" {
  value = azurerm_subnet.app.id
}
