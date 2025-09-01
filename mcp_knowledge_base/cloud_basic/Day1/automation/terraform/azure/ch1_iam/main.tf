terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" version = ">= 3.100.0" }
  }
}

provider "azurerm" { features {} }

variable "location" { type = string default = "koreacentral" }
variable "rg_name"  { type = string default = "rg-cloud-basic" }
variable "principal_object_id" { type = string }

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_role_assignment" "reader" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = var.principal_object_id
}

output "scope" { value = azurerm_resource_group.rg.id }

