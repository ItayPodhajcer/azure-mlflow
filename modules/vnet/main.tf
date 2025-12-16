resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.deployment_name}-${var.location}"
  address_space       = ["10.0.1.0/24", "10.0.2.0/23"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "resources" {
  name                              = "snet-${var.deployment_name}-resources-${var.location}"
  resource_group_name               = var.resource_group_name
  virtual_network_name              = azurerm_virtual_network.this.name
  address_prefixes                  = ["10.0.1.0/24"]
  private_endpoint_network_policies = "Disabled"
}

resource "azurerm_subnet" "app" {
  name                 = "snet-${var.deployment_name}-app-${var.location}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.2.0/23"]

  delegation {
    name = "snetfs-${var.deployment_name}-app-${var.location}"

    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
