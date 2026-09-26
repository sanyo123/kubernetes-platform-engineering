resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-platform-dev-uks-aks"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aks-platform-dev-uks"

  sku_tier = "Standard"
  oms_agent {

    log_analytics_workspace_id      = azurerm_log_analytics_workspace.aks.id
    msi_auth_for_monitoring_enabled = true
  }
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  node_provisioning_profile {
    mode               = "Manual"
    default_node_pools = "Auto"
  }

  default_node_pool {
    name                 = "system"
    vm_size              = "Standard_D2s_v4"
    auto_scaling_enabled = true

    min_count = 2
    max_count = 5

    vnet_subnet_id = azurerm_subnet.aks.id

    zones = ["1", "2", "3"]

    upgrade_settings {
      max_surge = "10%"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id

  }

  local_account_disabled = true

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"

    pod_cidr       = "10.244.0.0/16"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"

    outbound_type = "loadBalancer"
  }

  monitor_metrics {
    annotations_allowed = null
    labels_allowed      = null
  }


}


resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id

  mode    = "User"
  vm_size = "Standard_D2s_v4"

  auto_scaling_enabled = true
  upgrade_settings {
    max_surge = "10%"
  }
  min_count = 2
  max_count = 10

  vnet_subnet_id = azurerm_subnet.aks.id

  zones = ["1", "2", "3"]

  node_labels = {
    "workload" = "applications"
  }
}


