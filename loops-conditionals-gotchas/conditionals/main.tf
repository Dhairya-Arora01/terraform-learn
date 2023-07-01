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
  type = list(string)
  default = [ "arun", "varun", "tarun", "mcdonalds", "katrina" ]
}

# resource "azurerm_resource_group" "rg" {
#   for_each = {
#     for key, value in var.names : key => value if length(value) > 5
#   }

#   name = "rg-${each.value}"
#   location = "westus"
# }

output "name" {
  value = <<EOF
%{~ for name in var.names ~}
${name}%{if length(name)>5}, %{else}# %{endif}
%{~ endfor ~}
EOF
}

resource "random_integer" "random" {
  min = 2
  max = 9
}

output "random_value" {
  value = random_integer.random.result
}