output "sql_endpoint" {
  # Grabs the "sql" entry directly as a string
  value       = azurerm_synapse_workspace.syn.connectivity_endpoints["sql"]
  description = "The Synapse SQL endpoint URL"
}


output "connection_string" {
  # The connection string for the storage account.
  value = azurerm_storage_account.ST.primary_connection_string
  sensitive = true
}

