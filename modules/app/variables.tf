variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

variable "location" {
  description = "Location of the app"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the managed identity"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "storage_account_hostname" {
  description = "Hostname of the storage account"
  type        = string
}

variable "artifacts_container_name" {
  description = "Name of the storage container for MLflow artifacts"
  type        = string
}

variable "database_server" {
  description = "The hostname of the database server"
  type        = string
}

variable "database_name" {
  description = "The name of the database"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "database_username" {
  description = "Username for SQL Server authentication"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "Password for SQL Server authentication"
  type        = string
  sensitive   = true
}

variable "container_registry_server" {
  description = "The server URL of the Azure Container Registry"
  type        = string
}
