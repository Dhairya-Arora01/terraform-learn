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

variable "machine_names" {
  description = "Names of the machines"
  type        = map(any)
  default = {
    0 = "master"
    1 = "worker-1"
    2 = "worker-2"
  }
}

variable "machine_count" {
  description = "Count for the machines"
  type        = number
  default     = 3
}

variable "custom_tags" {
  default = {
    env     = "testing"
    created = "Dhairya"
  }
}