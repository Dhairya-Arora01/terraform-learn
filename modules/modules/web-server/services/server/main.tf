resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.server_name}-vm"
  resource_group_name   = "${var.server_name}-rg"
  location              = var.location
  size                  = var.size
  network_interface_ids = [var.nicId]

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
        publicIp = var.publicIp
        nicId = var.nicId
      })
    ]
  }
}