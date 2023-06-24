terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  backend "azurerm" {
    resource_group_name = "structural"
    storage_account_name = "dhairyasa02"
    container_name = "statefiles"
    key = "global/providers/global.tfstate"
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features{}
}

resource "azurerm_resource_group" "rg" {
  name     = "structural"
  location = "westus"
}

resource "azurerm_storage_account" "sa" {
  name                     = "dhairyasa02"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "statefiles"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}