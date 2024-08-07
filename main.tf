terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  backend "azurerm" {
    resource_group_name  = "${local.name_prefix_tf}-rg"
    storage_account_name = "${local.name_prefix_tf}-sa"
    container_name       = "${local.name_prefix_tf}-sc"
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
    location_map = {
        australiacentral = "auc",
        australiacentral2 = "auc2",
        australiaeast = "aue",
        australiasoutheast = "ause",
        brazilsouth = "brs",
        canadacentral = "cac",
        canadaeast = "cae",
        centralindia = "inc",
        centralus = "usc",
        eastasia = "ase",
        eastus = "use",
        eastus2 = "use2",
        francecentral = "frc",
        francesouth = "frs",
        germanynorth = "den",
        germanywestcentral = "dewc",
        japaneast = "jpe",
        japanwest = "jpw",
        koreacentral = "krc",
        koreasouth = "kre",
        northcentralus = "usnc",
        northeurope = "eun",
        norwayeast = "noe",
        norwaywest = "now",
        southafricanorth = "zan",
        southafricawest = "zaw",
        southcentralus = "ussc",
        southeastasia = "asse",
        southindia = "ins",
        switzerlandnorth = "chn",
        switzerlandwest = "chw",
        uaecentral = "aec",
        uaenorth = "aen",
        uksouth = "uks",
        ukwest = "ukw",
        westcentralus = "uswc",
        westeurope = "euw",
        westindia = "inw",
        westus = "usw",
        westus2 = "usw2",
    }
}

locals {
    environment_short = substr(var.environment, 0, 1)
    location_short = lookup(local.location_map, var.location, "aue")
}

# Name prefixes
locals {
    name_prefix = "${local.environment_short}-${local.location_short}"
    name_prefix_tf = "${local.name_prefix}-tf-${var.category}"
}

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
  name     = "${local.name_prefix_tf}-rg"
}

#
# Storage accounts
#

resource "azurerm_storage_account" "terraform_state" {
  name                     = "${local.name_prefix_tf}-sa"
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
  name                  = "${local.name_prefix_tf}-sc"
  storage_account_name  = azurerm_storage_account.terraform_state.name
  container_access_type = "private"
}
