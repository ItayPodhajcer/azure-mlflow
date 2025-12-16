variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

variable "location" {
  description = "Location of the database"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "administrator_login" {
  description = "Administrator login for the SQL server"
  type        = string
}

variable "administrator_password" {
  description = "Administrator login password for the SQL server"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the private link"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the managed identity that needs access to database"
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "ID of the vnet for the private link"
}
