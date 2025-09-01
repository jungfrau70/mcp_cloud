terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" version = ">= 3.100.0" }
  }
}

provider "azurerm" { features {} }

variable "location" { type = string default = "koreacentral" }
variable "rg_name" { type = string default = "rg-cloud-basic" }

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-basic"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    project     = var.project
    department  = var.department
    env         = var.env
    owner       = var.owner
    cost_center = var.cost_center
  }
}

resource "azurerm_subnet" "public" {
  name                 = "public-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "nat_pip" {
  name                = "pip-nat-gw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat_gw" {
  name                    = "nat-gw"
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  sku_name                = "Standard"
  public_ip_address_ids   = [azurerm_public_ip.nat_pip.id]
}

resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.2.0/24"]
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
}

output "vnet_id" { value = azurerm_virtual_network.vnet.id }
output "public_subnet_id" { value = azurerm_subnet.public.id }
output "private_subnet_id" { value = azurerm_subnet.private.id }

variable "project" { type = string default = "cloud-basic" }
variable "department" { type = string default = "it" }
variable "env" { type = string default = "lab" }
variable "owner" { type = string default = "student" }
variable "cost_center" { type = string default = "training" }

