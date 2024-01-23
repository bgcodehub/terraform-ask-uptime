resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }
}

data "azurerm_kubernetes_cluster" "current" {
  name                = azurerm_kubernetes_cluster.aks_cluster.name
  resource_group_name = azurerm_resource_group.aks_rg.name
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.current.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.current.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.current.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.current.kube_config[0].cluster_ca_certificate)
}

resource "kubernetes_deployment" "uptime_kuma" {
  metadata {
    name = "uptime-kuma"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "uptime-kuma"
      }
    }
    template {
      metadata {
        labels = {
          app = "uptime-kuma"
        }
      }
      spec {
        container {
          image = "louislam/uptime-kuma:1"
          name  = "uptime-kuma"
          port {
            container_port = 3001
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "uptime_kuma_service" {
  metadata {
    name = "uptime-kuma-service"
  }

  spec {
    selector = {
      app = "uptime-kuma"
    }
    port {
      port        = 80
      target_port = 3001
    }

    type = "LoadBalancer"
  }
}
