terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }

  backend "azurerm" {
    resource_group_name  = "structural"
    storage_account_name = "dhairyasa02"
    container_name       = "statefiles"
    key                  = "web-server/stage/services/server/server.tfstate"
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}

module "web-server-network" {
  source = "github.com/Dhairya-Arora01/web-server-tf-module//web-server/network?ref=v0.0.1"

  server_name = "staging-server"

}

module "web-server-server" {
  source = "../../modules/web-server/services/server"

  # assigning values to variables
  container_name = "statefiles"
  container_key  = "web-server/stage/services/server/server.tfstate"
  server_name    = "staging-server"
  nicId          = module.web-server-network.nicId
  publicIp       = module.web-server-network.public-ip
}