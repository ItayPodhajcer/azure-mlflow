resource "random_string" "this" {
  length  = 24
  special = false
  upper   = false
}

resource "azurerm_storage_account" "this" {
  name                          = random_string.this.result
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  public_network_access_enabled = false
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  name                          = "pl-storage-${var.deployment_name}-${var.location}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "nic-storage-${var.deployment_name}-${var.location}"

  private_service_connection {
    name                           = "psc-storage-${var.deployment_name}-${var.location}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.this.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.this.id]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = "link-${var.deployment_name}-${var.location}"
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "this" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_container.this.id
  principal_id         = var.managed_identity_id
}
