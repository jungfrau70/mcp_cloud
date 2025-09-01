terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" version = ">= 3.100.0" }
  }
}

provider "azurerm" { features {} }

variable "location" { type = string default = "koreacentral" }
variable "rg_name" { type = string default = "rg-cloud-basic" }
variable "account_name" { type = string default = null }

resource "random_id" "r" { byte_length = 4 }

locals { name = var.account_name != null ? var.account_name : "stor${random_id.r.hex}" }

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = local.name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website {
    index_document     = "index.html"
    error_404_document = "404.html"
  }
  tags = {
    project     = var.project
    department  = var.department
    env         = var.env
    owner       = var.owner
    cost_center = var.cost_center
  }
}

variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

output "static_website_url" { value = azurerm_storage_account.sa.primary_web_endpoint }

