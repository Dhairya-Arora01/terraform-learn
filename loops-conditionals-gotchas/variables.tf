variable "machine_count" {
  description = "The virtual machine counts"
  default = 3
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