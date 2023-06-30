resource "azurerm_resource_group" "rg" {
  name = "tricks-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name = "trick-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  address_space = [ "10.0.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  name = "trick-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = [ "10.0.0.0/24" ]
}

resource "azurerm_network_interface" "nic" {  

  count = var.machine_count
  # The below code would be iterated count number of times
  # Now this nic block becomes a list of nics azurerm_network_interface.nic = [0, 1, 2, ....]

  name = "trick-nic-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location

  ip_configuration {
    name = "Internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {

  count = var.machine_count

  name = "trick-vm-${count.index}"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  size = "Standard_B1s"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  network_interface_ids = [ azurerm_network_interface.nic[count.index].id ]

   os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.username
  admin_ssh_key {
    username   = var.username
    public_key = file("${var.key}.pub")
  }

}