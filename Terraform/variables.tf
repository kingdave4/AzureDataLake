# This file contains the variable definitions for the Terraform configuration.

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "AzureDatalake-RG"
}

variable "location" {
  description = "The Azure location where the resource group will be created"
  type        = string
  default     = "East US 2"
}

variable "storage_account_name" {
  description = "Base name for the storage account. A unique suffix will be appended automatically."
  type        = string
  default     = "datalakestorage"
}

variable "sql_admin_login" {
  description = "The SQL administrator login for the Synapse workspace"
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "The SQL administrator password for the Synapse workspace"
  type        = string
  sensitive   = true
}

variable "filesystem_name" {
  description = "The name of the filesystem in the storage account"
  type        = string
  default     = "synapse"
}

variable "synapse_workspace_name" {
  description = "The name of the Synapse workspace"
  type        = string
  default     = "datalakesynapse54"
}

variable "keyvault_name" {
  description = "The name of the Key Vault"
  type        = string
  default     = "mydatalakekeyvault48"
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
  sensitive = true
}

variable "function_app_name" {
  description = "The name of the Function App"
  type        = string
  default     = "datafunctionapp54"
}

variable "function_app_storage_account_name" {
  description = "The name of the storage account for the Function App"
  type        = string
  default     = "storagefunctionapp54"
}

variable "nba_endpoint" {
  description = "The NBA API endpoint"
  type        = string
  sensitive = true
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "mydatalake24"
}

variable "sp_object_id" {
  description = "Azure AD objectId of the Terraform or GitHub Service Principal. Must be an OBJECT ID, not App ID."
  type        = string
  sensitive = true
}

variable "apikey" {
  description = "API key for the NBA API"
  type        = string
  sensitive   = true
}

variable "container_name" {
  description = "The name of the container in the storage account"
  type        = string
  default     = "nba-datalake"
}
