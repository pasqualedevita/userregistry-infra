variable "location" {
  type    = string
  default = "westeurope"
}

variable "prefix" {
  type    = string
  default = "usrreg"
}

variable "env" {
  type = string
}

variable "env_short" {
  type = string
}

#
# 🔐 Key Vault
#
variable "key_vault_name" {
  type        = string
  description = "Key Vault name"
  default     = ""
}

variable "key_vault_rg_name" {
  type        = string
  default     = ""
  description = "Key Vault - rg name"
}

#
# ⛴ AKS
#
variable "aks_private_cluster_enabled" {
  type        = bool
  description = "Enable or not public visibility of AKS"
  default     = false
}

#
# ⛴ K8s
#

variable "k8s_kube_config_path_prefix" {
  type    = string
  default = "~/.kube"
}

# variable "k8s_apiserver_host" {
#   type = string
# }

variable "k8s_apiserver_port" {
  type    = number
  default = 443
}

variable "k8s_apiserver_insecure" {
  type    = bool
  default = false
}

variable "rbac_namespaces_for_deployer_binding" {
  type        = list(string)
  description = "Namespaces where to apply deployer binding rules"
}

# ingress

variable "ingress_replica_count" {
  type = string
}

variable "ingress_load_balancer_public_ip" {
  type        = string
  description = "Ingress load balance public ip"
}

variable "ingress_load_balancer_private_ip" {
  type        = string
  description = "Ingress load balance private IP to create during helm installation"
}

variable "default_service_port" {
  type    = number
  default = 8080
}

variable "nginx_helm_version" {
  type        = string
  description = "NGINX helm verison"
}

# # gateway
# variable "api_gateway_url" {
#   type = string
# }


# # configs/secrets
variable "configmaps_uservice-user-registry-management" {
  type = map(string)
}

#
# 🀄️ LOCALS
#
locals {
  project                  = "${var.prefix}-${var.env_short}"
  public_ip_resource_group_name = "${var.prefix}-${var.env_short}-vnet-rg"

  load_balancer_ip = var.aks_private_cluster_enabled ? var.ingress_load_balancer_private_ip : var.ingress_load_balancer_public_ip

  key_vault_id                    = "${data.azurerm_subscription.current.id}/resourceGroups/${var.key_vault_rg_name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
  
  appinsights_instrumentation_key = "InstrumentationKey=${module.key_vault_secrets_query.values["appinsights-instrumentation-key"].value}"

  # 🗄 Postgresql
  postgres_hostname               = "${local.project}-postgresql.postgres.database.azure.com"
  postgres_user_registry_connection_username = "USRREG_REGISTRY_USER@${local.postgres_hostname}"
  postgres_user_registry_connection_username_password = module.key_vault_secrets_query.values["postgres-user-registry-user-password"].value
}
