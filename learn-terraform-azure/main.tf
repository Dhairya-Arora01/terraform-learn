
# block terraform contains the terraform settings
terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }


  required_version = ">= 0.12"
}

#initializing the provider
provider "azurerm" {
  features {}
}

#creating the resource group
resource "azurerm_resource_group" "rg" {
  name     = "terra-rg"
  location = "westus"
}

#creating the vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "terra-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#subnet withing vnet
resource "azurerm_subnet" "subnet" {
  name                 = "terra-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

#creating the network interface
resource "azurerm_network_interface" "nic" {
  name                = "terra_nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# finally creating the vm and configuring it with the network
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "terravm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  size = "Standard_B1s"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = "adminuser"
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

}