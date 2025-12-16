resource "azurerm_mssql_server" "this" {
  name                                 = "sql-${var.deployment_name}-${var.location}"
  resource_group_name                  = var.resource_group_name
  location                             = var.location
  version                              = "12.0"
  administrator_login                  = var.administrator_login
  administrator_login_password         = var.administrator_password
  public_network_access_enabled        = false
  outbound_network_restriction_enabled = true
}

resource "azurerm_mssql_database" "this" {
  name                        = "sqldb-${var.deployment_name}"
  server_id                   = azurerm_mssql_server.this.id
  sku_name                    = "GP_S_Gen5_2"
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = 60
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  name                          = "pl-db-${var.deployment_name}-${var.location}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "nic-db-${var.deployment_name}-${var.location}"

  private_service_connection {
    name                           = "psc-db-${var.deployment_name}-${var.location}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
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
