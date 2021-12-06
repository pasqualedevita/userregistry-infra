module "key_vault_secrets_query" {
  source = "git::https://github.com/pagopa/azurerm.git//key_vault_secrets_query?ref=v1.0.58"

  resource_group = var.key_vault_rg_name
  key_vault_name = var.key_vault_name

  secrets = [
    "appinsights-instrumentation-key",
    "postgres-user-registry-user-password",
  ]
}
