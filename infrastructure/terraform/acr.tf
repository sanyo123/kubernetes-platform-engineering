resource "azurerm_container_registry" "aks" {
  name                = "aksplatformdevuksacr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Basic"
  admin_enabled       = false
}