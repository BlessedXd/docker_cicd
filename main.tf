terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "valeriy777_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "valeriy777_vnet" {
  name                = "valeriy777-vnet"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Subnet for App Service
resource "azurerm_subnet" "valeriy777_app_subnet" {
  name                 = "valeriy777-app-subnet"
  resource_group_name  = azurerm_resource_group.valeriy777_rg.name
  virtual_network_name = azurerm_virtual_network.valeriy777_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }

  service_endpoints = ["Microsoft.KeyVault"]
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "valeriy777_private_endpoint_subnet" {
  name                 = "valeriy777-private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.valeriy777_rg.name
  virtual_network_name = azurerm_virtual_network.valeriy777_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# App Service Plan
resource "azurerm_app_service_plan" "valeriy777_plan" {
  name                = "valeriy777-app-plan"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# App Service
resource "azurerm_app_service" "valeriy777_app" {
  name                = var.app_service_name
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  app_service_plan_id = azurerm_app_service_plan.valeriy777_plan.id
  identity {
    type = "SystemAssigned"
  }
   site_config {
    linux_fx_version = "DOCKER|valeriy777yo/docker_cicd:latest"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
}

# App Service VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "valeriy777_app_vnet_integration" {
  app_service_id = azurerm_app_service.valeriy777_app.id
  subnet_id      = azurerm_subnet.valeriy777_app_subnet.id
}

# Application Insights
resource "azurerm_application_insights" "valeriy777_ai" {
  name                = "valeriy777-app-insights"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  application_type    = "web"
}

# Container Registry
resource "azurerm_container_registry" "valeriy777_acr" {
  name                = "valeriy777acr"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  location            = azurerm_resource_group.valeriy777_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Key Vault
resource "azurerm_key_vault" "valeriy777_kv" {
  name                = "valeriy777-kv"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.valeriy777_app_subnet.id]
  }
}

# Role Assignment for App Service ACR Access
resource "azurerm_role_assignment" "app_service_acr_access" {
  scope                = azurerm_container_registry.valeriy777_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_app_service.valeriy777_app.identity[0].principal_id
}

# Key Vault Access Policy for App Service
resource "azurerm_key_vault_access_policy" "valeriy777_kv_policy" {
  key_vault_id = azurerm_key_vault.valeriy777_kv.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_app_service.valeriy777_app.identity[0].principal_id

  secret_permissions      = ["Get", "List"]
  certificate_permissions = ["Get", "List"]
}

# SQL Server
resource "azurerm_sql_server" "valeriy777_sql" {
  name                         = "tfvaleriy777sqlserver"
  resource_group_name          = azurerm_resource_group.valeriy777_rg.name
  location                     = azurerm_resource_group.valeriy777_rg.location
  version                      = "12.0"
  administrator_login          = var.admin_username
  administrator_login_password = var.admin_password
}

# SQL Database
resource "azurerm_sql_database" "valeriy777_sql_db" {
  name                = "valeriy777db"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  location            = azurerm_resource_group.valeriy777_rg.location
  server_name         = azurerm_sql_server.valeriy777_sql.name
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "valeriy777_sql_private_endpoint" {
  name                = "valeriy777-sql-private-endpoint"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  subnet_id           = azurerm_subnet.valeriy777_private_endpoint_subnet.id

  private_service_connection {
    name                           = "sqlPrivateEndpointConnection"
    private_connection_resource_id = azurerm_sql_server.valeriy777_sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

# Private DNS Zone for SQL Server
resource "azurerm_private_dns_zone" "valeriy777_sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
}

# Private DNS Zone Link for SQL Server
resource "azurerm_private_dns_zone_virtual_network_link" "valeriy777_sql_dns_vnet_link" {
  name                  = "valeriy777-sql-vnet-link"
  resource_group_name   = azurerm_resource_group.valeriy777_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.valeriy777_sql_dns.name
  virtual_network_id    = azurerm_virtual_network.valeriy777_vnet.id
}

# Storage Account
resource "azurerm_storage_account" "valeriy777_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.valeriy777_rg.name
  location                 = azurerm_resource_group.valeriy777_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Private Endpoint for Storage Account
resource "azurerm_private_endpoint" "valeriy777_storage_private_endpoint" {
  name                = "valeriy777-storage-private-endpoint"
  location            = azurerm_resource_group.valeriy777_rg.location
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
  subnet_id           = azurerm_subnet.valeriy777_private_endpoint_subnet.id

  private_service_connection {
    name                           = "storagePrivateEndpointConnection"
    private_connection_resource_id = azurerm_storage_account.valeriy777_storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

# Private DNS Zone for Storage Account
resource "azurerm_private_dns_zone" "valeriy777_storage_dns" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.valeriy777_rg.name
}

# Private DNS Zone Link for Storage Account
resource "azurerm_private_dns_zone_virtual_network_link" "valeriy777_storage_dns_vnet_link" {
  name                  = "valeriy777-storage-vnet-link"
  resource_group_name   = azurerm_resource_group.valeriy777_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.valeriy777_storage_dns.name
  virtual_network_id    = azurerm_virtual_network.valeriy777_vnet.id
}
