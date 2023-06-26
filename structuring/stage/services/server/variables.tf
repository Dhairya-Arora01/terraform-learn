variable "resource_group" {
  description = "The name of the resource group to be used."
  default     = "network-rg"
}

variable "location" {
  description = "Location for our resource"
  default     = "westus"
}

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