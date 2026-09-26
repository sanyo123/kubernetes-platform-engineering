resource "azurerm_user_assigned_identity" "python_web_app" {
  name                = "aks-platform-dev-uks-python-mi"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_federated_identity_credential" "python_web_app" {
  name = "python-web-app-fic"

  user_assigned_identity_id = azurerm_user_assigned_identity.python_web_app.id

  audience = [
    "api://AzureADTokenExchange"
  ]

  issuer  = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject = "system:serviceaccount:python-web-app:python-web-app-sa"
}