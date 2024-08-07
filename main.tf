terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  backend "azurerm" {
    resource_group_name  = "p-aue-tf-tfstate-rg"
    storage_account_name = "p-aue-tf-tfstate-sa"
    container_name       = "p-aue-tf-tfstate-sc"
    key                  = "prod.azure-ioc.tfstate"
  }
}

provider "azurerm" {
  features {}
}

#
# LOCALS
#

locals {
    common_tags = {
        category    = "${var.category}"
        environment = "${var.environment}"
        location    = "${var.location}"
        git_sha  = "${var.meta_git_sha}"
        version = "${var.meta_version}"
    }

    extra_tags = {
    }
}

#
# Resource group
#

resource "azurerm_resource_group" "rg" {
  location = "${var.location}"
  name     = "p-aue-tf-tfstate-rg"
}

#
# Storage accounts
#

resource "azurerm_storage_account" "terraform_state" {
  name                     = "p-aue-tf-tfstate-sa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge(
    local.common_tags,
    local.extra_tags,
    var.tags,
    {
        "purpose" = "terraform_state"
    } )
}

resource "azurerm_storage_container" "terraform_state_container" {
  name                  = "p-aue-tf-tfstate-sc"
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}
