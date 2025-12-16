provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.deployment_name}-${var.location}"
  location = var.location
}

resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "id-${var.deployment_name}-${azurerm_resource_group.this.location}"
  resource_group_name = azurerm_resource_group.this.name
}

module "vnet" {
  source = "./modules/vnet"

  deployment_name     = var.deployment_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

module "storage" {
  source = "./modules/storage"

  deployment_name     = var.deployment_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  subnet_id           = module.vnet.resources_subnet_id
  vnet_id             = module.vnet.vnet_id
  managed_identity_id = azurerm_user_assigned_identity.this.principal_id
  container_name      = "artifacts"
}

module "container_registry" {
  source = "./modules/container-registry"

  deployment_name     = var.deployment_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  base_version        = var.mlflow_base_version
  subnet_id           = module.vnet.resources_subnet_id
  vnet_id             = module.vnet.vnet_id
  github_repo_path    = var.github_repo_path
  github_token        = var.github_token
  managed_identity_id = azurerm_user_assigned_identity.this.principal_id
}

module "database" {
  source = "./modules/database"

  deployment_name        = var.deployment_name
  location               = azurerm_resource_group.this.location
  resource_group_name    = azurerm_resource_group.this.name
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password
  subnet_id              = module.vnet.resources_subnet_id
  vnet_id                = module.vnet.vnet_id
  managed_identity_id    = azurerm_user_assigned_identity.this.principal_id
}

module "app" {
  source = "./modules/app"

  deployment_name           = var.deployment_name
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  managed_identity_id       = azurerm_user_assigned_identity.this.id
  database_server           = module.database.server_hostname
  database_name             = module.database.database_name
  storage_account_hostname  = module.storage.primary_host
  artifacts_container_name  = module.storage.container_name
  subnet_id                 = module.vnet.app_subnet_id
  container_image           = "${module.container_registry.registry_login_server}/${module.container_registry.image_name}:${var.mlflow_base_version}"
  container_registry_server = module.container_registry.registry_login_server
  database_username         = var.administrator_login
  database_password         = var.administrator_password

  depends_on = [module.container_registry, module.database, module.storage]
}
