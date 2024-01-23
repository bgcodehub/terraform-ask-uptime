terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.74"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4"
    }
  }
}

provider "azurerm" {
  features {}
}