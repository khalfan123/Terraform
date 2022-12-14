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

provider "azurerm" {
  # Configuration options
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
  features {

  }
}