terraform {
  cloud {
    organization = "khalfan"

    workspaces {
      name = "getting-started"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.34.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  # Configuration options
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {

  }
}