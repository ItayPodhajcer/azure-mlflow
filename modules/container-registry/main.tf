locals {
  image_name = "${var.deployment_name}-custom"
}

resource "azurerm_container_registry" "this" {
  name                          = "cr${var.deployment_name}${var.location}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = "Premium"
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
}

resource "azurerm_private_dns_zone" "this" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  name                          = "pl-cr-${var.deployment_name}-${var.location}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "nic-cr-${var.deployment_name}-${var.location}"

  private_service_connection {
    name                           = "psc-cr-${var.deployment_name}-${var.location}"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_container_registry.this.id
    subresource_names              = ["registry"]
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

resource "azurerm_role_assignment" "app" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.this.id
  principal_id         = var.managed_identity_id
}

resource "azurerm_user_assigned_identity" "this" {
  location            = var.location
  resource_group_name = var.resource_group_name
  name                = "id-${var.deployment_name}-${var.location}"
}

resource "azurerm_container_registry_task" "this" {
  name                  = "${var.deployment_name}-task"
  container_registry_id = azurerm_container_registry.this.id

  identity {
    type = "SystemAssigned"
  }

  registry_credential {
    source {
      login_mode = "Default"
    }

    custom {
      login_server = azurerm_container_registry.this.login_server
      identity     = "[system]"
    }
  }

  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = var.github_repo_path
    context_access_token = var.github_token
    image_names          = ["${local.image_name}:${var.base_version}"]
    arguments = {
      "MLFLOW_VERSION" = var.base_version
    }
  }
}

resource "azurerm_role_assignment" "cr_task" {
  role_definition_name = "AcrPush"
  scope                = azurerm_container_registry.this.id
  principal_id         = azurerm_container_registry_task.this.identity.0.principal_id
}

resource "azurerm_container_registry_task_schedule_run_now" "this" {
  container_registry_task_id = azurerm_container_registry_task.this.id

  depends_on = [azurerm_role_assignment.cr_task]
}
