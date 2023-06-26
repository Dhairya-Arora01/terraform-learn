data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = "structural"
    storage_account_name = "dhairyasa02"
    container_name       = "statefiles"
    key                  = "stage/network/network.tfstate"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "server-vm"
  resource_group_name   = var.resource_group
  location              = var.location
  size                  = "Standard_B1s"
  network_interface_ids = [data.terraform_remote_state.network.outputs.nicId]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_username = var.username
  admin_ssh_key {
    username   = var.username
    public_key = file("${var.key}.pub")
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip_address
      user        = var.username
      private_key = file("${var.key}")
    }
    inline = [
      templatefile("./custom-input.sh", {
        publicIp = data.terraform_remote_state.network.outputs.public-ip
        nicId = data.terraform_remote_state.network.outputs.nicId
      })
    ]
  }
}