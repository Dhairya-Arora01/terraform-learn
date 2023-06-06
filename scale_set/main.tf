terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }

  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "auto-rg"
  location = "westus"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "auto-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "auto-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "auto-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  security_rule {
    name                       = "test"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ass" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "public_ip" {
  name                = "auto-pub-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

# resource "azurerm_network_interface" "nic" {
#   name = "auto-nic"
#   resource_group_name = azurerm_resource_group.rg.name
#   location = azurerm_resource_group.rg.location

#   ip_configuration {
#     name = "internal"
#     subnet_id = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id = azurerm_public_ip.public_ip.id
#   }
# }

variable "key" {
  description = "The key for sshing into the vm"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "username" {
  description = "The unsername of the user sshing"
  type        = string
  default     = "adminuser"
}

# scale set, similar to replica set
resource "azurerm_linux_virtual_machine_scale_set" "scale-set" {
  name                = "auto-scale-set"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  instances           = 2


  sku = "Standard_B1s"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
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

  network_interface {
    name    = "auto-nic"
    primary = true # there can be multiple nic for a vm , marking it as primary one.
    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend_address_pool.id]
    }
  }

  extension {
    name                 = "installNginx"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.1"

    settings = <<SETTINGS
    {
        "fileUris": ["https://raw.githubusercontent.com/Azure-Samples/compute-automation-configurations/master/automate_nginx_v2.sh"],
        "commandToExecute": "./automate_nginx_v2.sh"
    }
    SETTINGS
  }

}

resource "azurerm_monitor_autoscale_setting" "autoscaler" {

  name                = "auto-autoscaler"
  enabled             = true
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.scale-set.id

  profile {
    name = "defaultprofile"
    capacity {
      default = 2
      minimum = 2
      maximum = 5 # so minimum 2 and max of 5 instances would be there
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale-set.id
        time_grain         = "PT1M" # time granularity at which the metric data is collected
        statistic          = "Average"
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        time_window        = "PT5M" # time after which the collected data is analyzed
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action { # If the metric is triggered perform the following action
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M" # cooldown period during which no scaling action would take place
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.scale-set.id
        time_grain         = "PT1M" # time granularity at which the metric data is collected
        statistic          = "Average"
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"
        time_window        = "PT5M" # time after which the collected data is analyzed
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action { # If the metric is triggered perform the following action
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT1M" # cooldown period during which no scaling action would take place
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator = true
      custom_emails                      = ["dhairyarora0208in@gmail.com"]
    }
  }

}

resource "azurerm_lb" "lb" {
  name                = "auto-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIpAddress"
    public_ip_address_id = azurerm_public_ip.public_ip.id
  }

}

resource "azurerm_lb_backend_address_pool" "lb_backend_address_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "BackendAdressPool"
}

resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIpAddress"
}

output "ip_address" {
  value = azurerm_public_ip.public_ip
}