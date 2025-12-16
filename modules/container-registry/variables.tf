variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
}

variable "location" {
  description = "Location of database"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for the private link"
  type        = string
}

variable "github_repo_path" {
  description = "Path to the GitHub repository directory"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
}

variable "base_version" {
  description = "MLFlow docker image base version"
  type        = string
}

variable "managed_identity_id" {
  description = "ID of the managed identity"
  type        = string
}

variable "vnet_id" {
  type        = string
  description = "ID of the vnet for the private link"
}
