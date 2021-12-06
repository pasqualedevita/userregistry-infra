resource "azurerm_resource_group" "rg_vnet" {
  name     = format("%s-vnet-rg", local.project)
  location = var.location

  tags = var.tags
}

# vnet
module "vnet" {
  source              = "git::https://github.com/pagopa/azurerm.git//virtual_network?ref=v2.0.2"
  name                = format("%s-vnet", local.project)
  location            = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  address_space       = var.cidr_vnet

  tags = var.tags
}

## Application gateway public ip ##
resource "azurerm_public_ip" "appgateway_public_ip" {
  name                = format("%s-appgateway-pip", local.project)
  resource_group_name = azurerm_resource_group.rg_vnet.name
  location            = azurerm_resource_group.rg_vnet.location
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = var.tags
}

#
# 🗂 AKS public IP
#
resource "azurerm_public_ip" "aks_outbound" {
  count = var.aks_num_outbound_ips

  name                = format("%s-aksoutbound-pip-%02d", local.project, count.index + 1)
  location            = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  sku                 = "Standard"
  allocation_method   = "Static"

  tags = var.tags
}

#
# 🗂 VPN public IP
#

resource "random_string" "vpn_dns" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_public_ip" "vpn_gw" {
  count               = var.vpn_enabled ? 1 : 0
  name                = format("%s-vpn-gw-pip", local.project)
  location            = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  allocation_method = "Dynamic"
  domain_name_label = format("%sgw%s", lower(replace(format("%s-vpn-gw-pip", local.project), "/[[:^alnum:]]/", "")), random_string.vpn_dns.result)
  sku               = "Basic"

  tags = var.tags
}
