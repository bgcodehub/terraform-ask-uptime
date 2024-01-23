output "aks_cluster_endpoint" {
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].host
  description = "The endpoint for the created AKS cluster"
}

output "uptime_kuma_service_external_ip" {
  value       = kubernetes_service.uptime_kuma_service.status[0].load_balancer[0].ingress[0].ip
  description = "The external IP address to access Uptime-Kuma"
}