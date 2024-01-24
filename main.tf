# Resource Group
resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

# AKS Cluster
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

# AKS Cluster Data
data "azurerm_kubernetes_cluster" "current" {
  name                = azurerm_kubernetes_cluster.aks_cluster.name
  resource_group_name = azurerm_resource_group.aks_rg.name
}

# Kubernetes Provider Configuration
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.current.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.current.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.current.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.current.kube_config[0].cluster_ca_certificate)
}

# Persistent Volume Claim
resource "kubernetes_persistent_volume_claim" "uptime_kuma_pvc" {
  metadata {
    name = "uptime-kuma-pvc"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "default"
  }
}

# Deploy Uptime-Kuma with a reference to the PVC for persistent storage
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

          volume_mount {
            mount_path = "/data"
            name       = "uptime-kuma-storage"
          }
        }

        # Define volumes using the PVC
        volume {
          name = "uptime-kuma-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.uptime_kuma_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# Expose Uptime-Kuma via a LoadBalancer Service
resource "kubernetes_service" "uptime_kuma_service" {
  metadata {
    name = "uptime-kuma-service"
  }

  spec {
    selector = {
      app = "uptime-kuma"
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 3001
    }
  }
}

# Authentik Deployment
resource "kubernetes_deployment" "authentik" {
  metadata {
    name = "authentik"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "authentik"
      }
    }
    template {
      metadata {
        labels = {
          app = "authentik"
        }
      }
      spec {
        container {
          image = "goauthentik.io/authentik"
          name  = "authentik"
          # Specify ports, environment variables, volume mounts etc.
        }
        # Define volumes if necessary
      }
    }
  }
}

# Authentik Service
resource "kubernetes_service" "authentik_service" {
  metadata {
    name = "authentik-service"
  }
  spec {
    selector = {
      app = "authentik"
    }
    type = "ClusterIP"
    port {
      port        = 80 # Adjust as needed
      target_port = 80 # Adjust as needed
    }
  }
}

# Nginx Deployment
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "nginx"
      }
    }
    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "nginx"
          port {
            container_port = 80
          }
          // Additional configuration such as volume mounts for custom config
        }
        // Additional configuration such as volumes for custom config
      }
    }
  }
}

# Nginx Service
resource "kubernetes_service" "nginx_service" {
  metadata {
    name = "nginx-service"
  }
  spec {
    selector = {
      app = "nginx"
    }
    type = "LoadBalancer"
    port {
      port        = 80 # HTTP
      target_port = 80
    }
    port {
      port        = 443 # HTTPS
      target_port = 443
    }
  }
}
