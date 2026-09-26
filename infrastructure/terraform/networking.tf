resource "azurerm_resource_group" "aks" {
  name     = "aks-platform-dev-uks-rg"
  location = "uksouth"
}

resource "azurerm_virtual_network" "aks" {
  name                = "aks-platform-dev-uks-vnet"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "aks-nodes-snet"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["10.10.0.0/22"]
}