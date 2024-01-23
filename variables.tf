variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the AKS cluster"
  default     = 1
}

variable "vm_size" {
  description = "Size of the VMs in the node pool"
  default     = "Standard_DS2_v2"
}

variable "client_id" {
  description = "The Client ID for the AKS Service Principal"
  type        = string
}

variable "client_secret" {
  description = "The Client Secret for the AKS Service Principal"
  type        = string
}