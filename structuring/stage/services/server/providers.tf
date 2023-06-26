terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "structural"
    storage_account_name = "dhairyasa02"
    container_name       = "statefiles"
    key                  = "stage/services/server/server.tfstate"
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}