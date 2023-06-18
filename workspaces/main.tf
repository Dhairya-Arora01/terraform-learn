terraform {
  required_providers{
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name = "tfstate-rg"
    storage_account_name = "dhairyatfsa"
    container_name = "tfstatescontainer"
    key = "workspace-example/terraform.tfstate"  # so the state file would be stored in workspace-example folder
  }

  required_version = ">= 0.12"
}

# if workspace is default : state file in workspace-example folder without any tags
# if I created and switched to a new workspace name example-1 then state file would be stored in workspace-example folder and it would be tagged with :example-1
# so the final name would be workspace-example/terraform.tfstateenv:example-1