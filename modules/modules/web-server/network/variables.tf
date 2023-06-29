variable "location" {
  description = "Location for our resource"
  default     = "westus"
}

variable "server_name" {
  description = "Naming for the whole setup also be used for naming convention"
  type = string
}

# module locals

locals {
  protocol = "Tcp"
  port_range = "*"
  address = "10.0.0.0"
}