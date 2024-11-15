output "app_service_default_hostname" {
  description = "The default hostname for the App Service"
  value       = azurerm_app_service.valeriy777_app.default_site_hostname
}

output "sql_server_fqdn" {
  description = "The FQDN for the SQL Server"
  value       = azurerm_sql_server.valeriy777_sql.fully_qualified_domain_name
}

output "storage_account_primary_key" {
  description = "The primary key for the Storage Account"
  value       = azurerm_storage_account.valeriy777_storage.primary_access_key
  sensitive   = true
}