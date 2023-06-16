terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "dhairyatfsa"
    container_name       = "tfstatescontainer"
    key                  = "terraform.tf" # key under which the state file would be stored
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "tfstate-rg"
  location = "westus"
}

resource "azurerm_storage_account" "storage_account" {
  name                     = "dhairyatfsa" #name of storage account should be unique across the azure cloud
  location                 = "westus"
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
  }

}

resource "azurerm_storage_container" "storage_container" {
  name                 = "tfstatescontainer" # these are logical division of azure storage account so that we can store blobs
  storage_account_name = azurerm_storage_account.storage_account.name
  container_access_type = "private"   # doesn't allow public traffic
}

# locks for blobs in azure is automatically configured by tf