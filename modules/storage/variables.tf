variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the storage account"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the managed identity that needs access to the storage container"
  type        = string
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "ID of the vnet for the private link"
}
