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
    key                  = "web-server/prod/services/server/server.tfstate"
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}

module "web-server-network" {
  source = "../../modules/web-server/network"

  server_name = "prod-server"

}

module "web-server-server" {
  source = "../../modules/web-server/services/server"

  # assigning values to variables
  container_name = "statefiles"
  container_key  = "web-server/stage/services/server/server.tfstate"
  server_name    = "staging-server"
  nicId          = module.web-server-network.nicId
  publicIp       = module.web-server-network.public-ip
  env            = "production"
}