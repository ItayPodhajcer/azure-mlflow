locals {
  artifacts_uri = "wasbs://${var.artifacts_container_name}@${var.storage_account_hostname}/"
  database_uri  = "mssql+pyodbc://${var.database_username}:${var.database_password}@${var.database_server}/${var.database_name}?driver=ODBC+Driver+17+for+SQL+Server"
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.deployment_name}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "this" {
  name                               = "cae-${var.deployment_name}-${var.location}"
  location                           = var.location
  resource_group_name                = var.resource_group_name
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.this.id
  logs_destination                   = "log-analytics"
  infrastructure_subnet_id           = var.subnet_id
  infrastructure_resource_group_name = "rg-${var.deployment_name}-infra-${var.location}"

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 1
    minimum_count         = 0
  }
}

resource "azurerm_container_app" "this" {
  name                         = "ca-${var.deployment_name}-${var.location}"
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  registry {
    server   = var.container_registry_server
    identity = var.managed_identity_id
  }

  ingress {
    external_enabled = true
    target_port      = 5000
    transport        = "http"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    max_replicas = 1
    min_replicas = 0

    container {
      name   = "mlflow"
      image  = var.container_image
      cpu    = 2
      memory = "4Gi"

      env {
        name  = "MLFLOW_DEFAULT_ARTIFACT_ROOT"
        value = local.artifacts_uri
      }

      env {
        name  = "MLFLOW_BACKEND_STORE_URI"
        value = local.database_uri
      }

      env {
        name  = "MLFLOW_ARTIFACT_UPLOAD_DOWNLOAD_TIMEOUT"
        value = 600
      }

      liveness_probe {
        path      = "/"
        port      = 5000
        transport = "HTTP"
      }

      readiness_probe {
        path      = "/"
        port      = 5000
        transport = "HTTP"
      }
    }
  }
}
