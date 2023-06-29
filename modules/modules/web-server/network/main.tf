resource "azurerm_resource_group" "rg" {
  name     = "${var.server_name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.server_name}-network-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["${local.address}/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.server_name}-network-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${local.address}/24"]
}

resource "azurerm_public_ip" "publicIp" {
  name                = "${var.server_name}-network-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.server_name}-network-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "test"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = local.protocol
    source_port_range          = local.port_range
    destination_port_range     = "80"
    source_address_prefix      = local.port_range
    destination_address_prefix = local.port_range
  }

  security_rule {
    name                       = "ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = local.protocol
    source_port_range          = local.port_range
    destination_port_range     = "22"
    source_address_prefix      = local.port_range
    destination_address_prefix = local.port_range
  }
}

resource "azurerm_subnet_network_security_group_association" "association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.server_name}-network-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "Internal"
    public_ip_address_id          = azurerm_public_ip.publicIp.id
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}