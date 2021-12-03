# general
env_short = "p"
env       = "prod"
location  = "westeurope"

tags = {
  CreatedBy   = "Terraform"
  Environment = "Prod"
  Owner       = "UserRegistry"
  Source      = "https://github.com/pagopa/userregistry-infra"
  CostCenter  = "TS310 - PAGAMENTI & SERVIZI"
}

lock_enable = true

# 🔐 key vault
key_vault_name    = "usrreg-p-kv-weu"
key_vault_rg_name = "usrreg-p-sec-rg-weu"

# ☁️ networking
cidr_vnet              = ["10.1.0.0/16"]
cidr_subnet_appgateway = ["10.1.128.0/24"]
cidr_subnet_postgres   = ["10.1.129.0/24"]
cidr_subnet_azdoa      = ["10.1.130.0/24"]
cidr_subnet_cosmosdb   = ["10.1.131.0/24"]
cidr_subnet_apim       = ["10.1.136.0/24"]
cidr_subnet_k8s        = ["10.1.0.0/17"]

# dns
dns_zone_prefix = "userregistry"
external_domain = "pagopa.it"

# azure devops
enable_azdoa        = true
enable_iac_pipeline = true

# ❇️ app_gateway
app_gateway_sku_name             = "Standard_v2" # TODO change to WAF_v2
app_gateway_sku_tier             = "Standard_v2" # TODO change to WAF_v2
app_gateway_alerts_enabled       = false         # TODO change to true
app_gateway_waf_enabled          = false         # TODO change to true
app_gateway_api_certificate_name = "api-userregistry-pagopa-it"

# postgres
postgres_private_endpoint_enabled      = true
postgres_sku_name                      = "GP_Gen5_2"
postgres_byok_enabled                  = true
postgres_public_network_access_enabled = false
postgres_geo_redundant_backup_enabled  = true
postgres_alerts_enabled                = true

# cosmosdb
cosmosdb_byok_enabled             = true
cosmosdb_first_setup_byok         = true
cosmosdb_private_endpoint_enabled = true

#
# 🗺 APIM
#
apim_publisher_name                = "PagoPA SelfCare PROD"
apim_sku                           = "Developer_1" # TODO change to Premium_1
apim_api_internal_certificate_name = "api-internal-userregistry-pagopa-it"

#
# ⛴ AKS
#
aks_private_cluster_enabled = true
aks_alerts_enabled          = true
# This is the k8s ingress controller ip. It must be in the aks subnet range.
reverse_proxy_ip        = "10.1.0.250"
aks_max_pods            = 100
aks_enable_auto_scaling = true
aks_node_min_count      = 1
aks_node_max_count      = 3
aks_vm_size             = "Standard_D4s_v3"

