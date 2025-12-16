variable "deployment_name" {
  description = "Name of the deployment"
  type        = string
  default     = "mlflow"
}

variable "location" {
  description = "Location of the deployment"
  type        = string
  default     = "eastus2"
}

variable "administrator_login" {
  description = "Administrator login for the SQL server"
  type        = string
  sensitive   = true
}

variable "administrator_password" {
  description = "Administrator login password for the SQL server"
  type        = string
  sensitive   = true
}

variable "github_repo_path" {
  description = "Path to the GitHub repository directory"
  type        = string
}

variable "github_token" {
  description = "GitHub token"
  type        = string
}

variable "mlflow_base_version" {
  description = "MLFlow docker image base version"
  type        = string
}
