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

variable "container_name" {
  description = "Name of the container to be used for storing the statefile"
  type = string
}

variable "container_key" {
  description = "key in the key-value pair for storing the state file"
  type = string
}

variable "server_name" {
  description = "Naming for the whole setup also be used for naming convention"
  type = string
}

variable "nicId" {
  description = "The id of the network interface"
  type = string
}

variable "publicIp" {
  description = "The public ip address"
  type = string
}

variable "env" {
  description = "Environment for deployment"
  default = "staging"
}