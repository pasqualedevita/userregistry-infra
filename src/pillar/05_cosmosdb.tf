# APIM subnet
module "cosmosdb_snet" {
  source               = "git::https://github.com/pagopa/azurerm.git//subnet?ref=v1.0.58"
  name                 = format("%s-cosmos-snet", local.project)
  resource_group_name  = azurerm_resource_group.rg_vnet.name
  virtual_network_name = module.vnet.name
  address_prefixes     = var.cidr_subnet_cosmosdb

  enforce_private_link_endpoint_network_policies = true
  service_endpoints                              = ["Microsoft.Web"]
}

module "cosmosdb" {
  source     = "/Users/pasqualedevita/Documents/github/azurerm/cosmosdb"
  depends_on = [azurerm_key_vault_access_policy.azure_cosmosdb]

  name                = format("%s-cosmos", local.project)
  location            = azurerm_resource_group.data_rg.location
  resource_group_name = azurerm_resource_group.data_rg.name
  kind                = "GlobalDocumentDB"
  offer_type          = var.cosmosdb_offer_type
  capabilities        = concat(["EnableCassandra"], var.cosmosdb_extra_capabilities)

  public_network_access_enabled     = var.env_short == "p" ? false : var.cosmosdb_public_network_access_enabled
  private_endpoint_enabled          = var.cosmosdb_private_endpoint_enabled
  subnet_id                         = module.cosmosdb_snet.id
  private_dns_zone_ids              = [azurerm_private_dns_zone.privatelink_cassandra_cosmos_azure_com.id]
  is_virtual_network_filter_enabled = true

  consistency_policy = var.cosmosdb_consistency_policy

  main_geo_location_location = azurerm_resource_group.data_rg.location

  additional_geo_locations = var.cosmosdb_additional_geo_locations

  backup_continuous_enabled = false # not supported with cassandra and byok

  key_vault_key_id = var.cosmosdb_byok_enabled ? azurerm_key_vault_key.cosmosdb[0].versionless_id : null

  tags = var.tags
}

# Microsoft application needs to access to keyvault on first setup cosmosdb
# https://docs.microsoft.com/en-us/azure/cosmos-db/how-to-setup-cmk#add-access-policy
resource "azurerm_key_vault_access_policy" "azure_cosmosdb" {
  count = var.cosmosdb_byok_enabled && var.cosmosdb_first_setup_byok ? 1 : 0

  key_vault_id            = data.azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = var.azuread_service_principal_azure_cosmos_db
  key_permissions         = ["Get", "WrapKey", "UnwrapKey"]
  secret_permissions      = []
  certificate_permissions = []
  storage_permissions     = []
}

resource "azurerm_key_vault_access_policy" "cosmosdb" {
  count = var.cosmosdb_byok_enabled ? 1 : 0

  key_vault_id            = data.azurerm_key_vault.kv.id
  tenant_id               = data.azurerm_client_config.current.tenant_id
  object_id               = module.cosmosdb.principal_id
  key_permissions         = ["Get", "WrapKey", "UnwrapKey"]
  secret_permissions      = []
  certificate_permissions = []
  storage_permissions     = []
}

resource "azurerm_key_vault_key" "cosmosdb" {
  count = var.cosmosdb_byok_enabled ? 1 : 0

  name         = "cosmosdb-key"
  key_vault_id = data.azurerm_key_vault.kv.id
  key_type     = "RSA-HSM"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags
}
