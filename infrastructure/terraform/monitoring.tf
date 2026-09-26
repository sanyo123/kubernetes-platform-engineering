resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-platform-dev-uks-law"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name

  sku               = "PerGB2018"
  retention_in_days = 30
}

resource "azurerm_monitor_workspace" "aks" {
  name                = "aks-platform-dev-uks-amw"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
}


resource "azurerm_monitor_data_collection_rule" "prometheus" {
  name                = "aks-platform-dev-uks-prometheus-dcr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  kind = "Linux"

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.aks.id
      name               = "prometheus"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["prometheus"]
  }

  data_sources {
    prometheus_forwarder {
      streams = ["Microsoft-PrometheusMetrics"]
      name    = "prometheus-forwarder"
    }
  }
}


resource "azurerm_monitor_data_collection_rule_association" "prometheus" {
  name                    = "aks-platform-dev-uks-prometheus-dcra"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus.id
}

resource "azurerm_dashboard_grafana" "aks" {
  name                = "aks-platform-dev-graf"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location

  grafana_major_version = "12"

  identity {
    type = "SystemAssigned"
  }
  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.aks.id
  }
}

resource "azurerm_monitor_data_collection_rule" "container_insights" {
  name                = "aks-platform-dev-uks-container-insights-dcr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  kind                = "Linux"

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.aks.id
      name                  = "log-analytics"
    }
  }

  data_flow {
    streams = [
      "Microsoft-ContainerLogV2",
      "Microsoft-KubeEvents",
      "Microsoft-KubePodInventory"
    ]

    destinations = ["log-analytics"]
  }

  data_sources {
    extension {
      name           = "ContainerInsightsExtension"
      extension_name = "ContainerInsights"

      streams = [
        "Microsoft-ContainerLogV2",
        "Microsoft-KubeEvents",
        "Microsoft-KubePodInventory"
      ]

      extension_json = jsonencode({
        dataCollectionSettings = {
          interval               = "1m"
          namespaceFilteringMode = "Off"
          namespaces             = []
          enableContainerLogV2   = true
        }
      })
    }
  }
}

resource "azurerm_monitor_data_collection_rule_association" "container_insights" {
  name                    = "aks-platform-dev-uks-container-insights-dcra"
  target_resource_id      = azurerm_kubernetes_cluster.aks.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.container_insights.id
}