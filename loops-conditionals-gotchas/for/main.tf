terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0.2"
    }
  }
  required_version = ">=0.12"
}

provider "azurerm" {
  features {}
}

variable "names" {
  type    = list(string)
  default = ["arun", "varun", "tarun", "vishakha", "malkova", "socroatic"]
}

variable "tools" {
  type = map(string)
  default = {
    "docker" = "container"
    "kubernetes" = "orchestration"
    "azure" = "cloud"
    "terraform" = "iac"
  }
}

output "names" {
  value = {for index, name in var.names : index => upper(name) if length(name) > 5}
}

output "tools" {
  # for a map the key-value pair would be iterated alphabetically based on the key
  value = [for tool, type in var.tools : "${upper(tool)} is used for ${lower(type)}"]
}

output "map_tools" {
  description = "Will output map of tools with both key and value in uppercase."
  # map comprehension
  value = {for tool, type in var.tools : upper(tool) => upper(type)}
}

output "string_directive" {
  value = "%{for name in var.names}${name}, %{endfor}"
}

output "strings" {
  value = "%{for index, name in var.names}(${index})${name}, %{endfor}"
}