terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }
  }
}


provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}


data "azurerm_client_config" "current" {}


resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}


resource "azurerm_storage_account" "ST" {
  name                   = "${lower(var.storage_account_name)}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true                                       
}

resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_id  = azurerm_storage_account.ST.id
  container_access_type = "blob"
}


resource "azurerm_storage_data_lake_gen2_filesystem" "fs" {
  name               = var.filesystem_name
  storage_account_id = azurerm_storage_account.ST.id
}


resource "azurerm_synapse_workspace" "syn" {
  name                             = var.synapse_workspace_name
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  sql_administrator_login          = var.sql_admin_login
  sql_administrator_login_password = var.sql_admin_password

  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.fs.id

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_role_assignment" "synapse_data_contrib" {
  scope                = azurerm_storage_account.ST.id
  role_definition_name = "Storage Blob Data Contributor"                 
  principal_id         = azurerm_synapse_workspace.syn.identity[0].principal_id
  depends_on           = [azurerm_synapse_workspace.syn]
}


resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
}


resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "Set",
    "List",
    "Delete",
    "Recover",
  ]
}

resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_function_app.nba_refresh.identity[0].principal_id
  depends_on   = [azurerm_linux_function_app.nba_refresh]
  secret_permissions = [
    "Get",
    "List",
  ]
}


resource "azurerm_key_vault_secret" "storage_conn" {
  name         = "StorageConnectionString"
  value        = azurerm_storage_account.ST.primary_connection_string
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_sp]
}


resource "azurerm_key_vault_secret" "MyApikey" {
  name         = "SportsDataApikey"
  value        = var.apikey
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_sp]
}


resource "azurerm_key_vault_secret" "sql_administrator_login_passwordT" {
  name         = "MySqlAdminPassword"
  value        = var.sql_admin_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.terraform_sp]
}


// Updated App Service Plan using azurerm_service_plan
resource "azurerm_service_plan" "func_plan" {
  name                = "${var.prefix}-func-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_log_analytics_workspace" "la" {
  name                = "${var.prefix}-law"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
}

resource "azurerm_application_insights" "ai" {
  name                = "${var.prefix}-ai"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id = azurerm_log_analytics_workspace.la.id
}


// Updated Linux Function App definition
resource "azurerm_linux_function_app" "nba_refresh" {
  name                       = var.function_app_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  service_plan_id            = azurerm_service_plan.func_plan.id
  storage_account_name     = "${lower(var.storage_account_name)}${random_string.suffix.result}"
  storage_account_access_key = azurerm_storage_account.ST.primary_access_key
  functions_extension_version = "~4"
  

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "KEY_VAULT_NAME" = azurerm_key_vault.kv.name
    "NBA_ENDPOINT"   = var.nba_endpoint
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.ai.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.ai.connection_string
  }
   depends_on = [azurerm_application_insights.ai]
}

resource "azurerm_monitor_diagnostic_setting" "func_diagnostics" {
  name                       = "funcDiagnostics"
  target_resource_id         = azurerm_linux_function_app.nba_refresh.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.la.id
  
  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
  
}


