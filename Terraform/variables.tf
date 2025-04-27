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
  description = "The name of the storage account"
  type        = string
  default     = "datalakestorage281"
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
# Note: The password should be strong and meet Azure's requirements for SQL administrator passwords.


variable "filesystem_name" {
  description = "The name of the filesystem in the storage account"
  type        = string
  default     = "synapse"

}


variable "synapse_workspace_name" {
  description = "The name of the Synapse workspace"
  type        = string
  default     = "datalakesynapse28"
  
}

variable "keyvault_name" {
  description = "The name of the Key Vault"
  type        = string
  default     = "mydatalakekeyvault2" 
}

variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "function_app_name" {
  description = "The name of the Function App"
  type        = string
  default     = "myfunctionappking32"
  
}

variable "function_app_storage_account_name" {
  description = "The name of the storage account for the Function App"
  type        = string
  default     = "myfunctionapp"
}

variable "nba_endpoint" {
  description = "The NBA API endpoint"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "mydatalake431"
}

variable "sp_object_id" {
  description = "Azure AD objectId of the GitHub Service Principal"
  type        = string
}

variable "apikey" {
  description = "API key for the NBA API"
  type        = string
  sensitive   = true
}


