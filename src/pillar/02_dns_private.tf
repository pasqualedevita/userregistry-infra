resource "azurerm_private_dns_zone" "internal" {
  count               = (var.dns_zone_prefix == null || var.external_domain == null) ? 0 : 1
  name                = join(".", ["internal", var.dns_zone_prefix, var.external_domain])
  resource_group_name = azurerm_resource_group.rg_vnet.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "internal_vnet" {
  name                  = format("%s-vnet", local.project)
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.internal[0].name
  virtual_network_id    = module.vnet.id
}

resource "azurerm_private_dns_zone" "privatelink_postgres_database_azure_com" {
  count               = var.postgres_private_endpoint_enabled ? 1 : 0
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_postgres_database_azure_com_vnet" {
  count                 = var.postgres_private_endpoint_enabled ? 1 : 0
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_postgres_database_azure_com[0].name
  virtual_network_id    = module.vnet.id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone" "privatelink_cassandra_cosmos_azure_com" {
  count               = var.cosmosdb_private_endpoint_enabled ? 1 : 0
  name                = "privatelink.cassandra.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_cassandra_cosmos_azure_com_vnet" {
  count                 = var.cosmosdb_private_endpoint_enabled ? 1 : 0
  name                  = module.vnet.name
  resource_group_name   = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_cassandra_cosmos_azure_com[0].name
  virtual_network_id    = module.vnet.id
  registration_enabled  = false

  tags = var.tags
}
