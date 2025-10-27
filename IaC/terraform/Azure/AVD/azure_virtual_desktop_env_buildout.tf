# Date Created: 10/27/2025
# This Terraform template builds out an Azure Virtual Desktop environment from scratch in the Azure regions of East US, and West US. OKTA users, and groups are synced from 
# OKTA to Microsoft Entra via SAML/SCIM to assign the roles as needed (Desktop Virtual User, Virtual Machine User Login, Virtual Machine 
# Administrator Login) for both regular and administrative users to log into their Azure Virtual Deskop(s). Additionally this deployment 
# creates two Azure Virtual networks of 10.100.0.0/16 and 10.101.0.0/16 with internet access using static WAN IP addresses. 

# Declare Terraform Modules to be used

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

# Add your the Microsoft Azure subscription ID 

provider "azurerm" {
  features {}

  subscription_id = "####-####-####-####-#######"
}

# Manages Entra Directory for Users Groups, Service Principals, App Registrations, and Role Assignments
provider "azuread" {}


#---------------------------------------------------
# Global Resource Group Creation Per region
#---------------------------------------------------

# Resource Groups Creation
# Resource Group 0
resource "azurerm_resource_group" "group0" {
  name     = "virtual_desktops_uswest"
  location = "West US"
}

# Resource Group 1
resource "azurerm_resource_group" "group1" {
  name     = "virtual_desktops_useast"
  location = "East US"
}

# Resource Groups to Role assignments

#---------------------------------------------------
# East US VDI User Roles to OKTA Group(s)
#---------------------------------------------------

# Look up the East US Resource Group
data "azurerm_resource_group" "virtual_desktops_useast" {
  name = "virtual_desktops_useast"
}

# Look up the East US Entra Group for Users
data "azuread_group" "vdi_users_useast" {
  display_name = "azure-vdi-users-useast"
}

# Assignment 1: East US - Virtual Desktop User role
resource "azurerm_role_assignment" "vdi_user_role_useast" {
  scope                = data.azurerm_resource_group.virtual_desktops_useast.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azuread_group.vdi_users_useast.object_id
}

# Assignment 2: East US - Desktop Virtualization User role
resource "azurerm_role_assignment" "desktop_virtualization_user_role_useast" {
  scope                = data.azurerm_resource_group.virtual_desktops_useast.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = data.azuread_group.vdi_users_useast.object_id
}


#---------------------------------------------------
# West US VDI User Roles to OKTA Group(s)
#---------------------------------------------------

# Look up the West US Resource Group
data "azurerm_resource_group" "virtual_desktops_uswest" {
  name = "virtual_desktops_uswest"
}

# Look up the West US Entra Group for Users
data "azuread_group" "vdi_users_uswest" {
  display_name = "azure-vdi-users-uswest"
}

# Assignment 3: West US - Virtual Desktop User role
resource "azurerm_role_assignment" "vdi_user_role_uswest" {
  scope                = data.azurerm_resource_group.virtual_desktops_uswest.id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = data.azuread_group.vdi_users_uswest.object_id
}

# Assignment 4: West US - Desktop Virtualization User role
resource "azurerm_role_assignment" "desktop_virtualization_user_role_uswest" {
  scope                = data.azurerm_resource_group.virtual_desktops_uswest.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = data.azuread_group.vdi_users_uswest.object_id
}


#---------------------------------------------------
# East US VDI Administrator Roles to OKTA Group(s)
#---------------------------------------------------

# Look up the East US Entra Group for Admins
data "azuread_group" "vdi_admin_users_useast" {
  display_name = "azure-vdi-admin-users-useast"
}

# Assignment 5: East US - Virtual Machine Administrator Login role
resource "azurerm_role_assignment" "vm_admin_login_useast" {
  scope                = data.azurerm_resource_group.virtual_desktops_useast.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_group.vdi_admin_users_useast.object_id
}


#---------------------------------------------------
# West US VDI Administrator Roles to OKTA Group(s)
#---------------------------------------------------

# Look up the West US Entra Group for Admins
data "azuread_group" "vdi_admin_users_uswest" {
  display_name = "azure-vdi-admin-users-uswest"
}

# Assignment 6: West US - Virtual Machine Administrator Login role
resource "azurerm_role_assignment" "vm_admin_login_uswest" {
  scope                = data.azurerm_resource_group.virtual_desktops_uswest.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azuread_group.vdi_admin_users_uswest.object_id
}

#---------------------------------------------------
# East US Network Resources
#---------------------------------------------------

# Look up the existing East US Resource Group
data "azurerm_resource_group" "rg_useast" {
  name = "virtual_desktops_useast"
}

# Create the East US Virtual Network in the existing RG
resource "azurerm_virtual_network" "vnet_useast" {
  name                = "virtual_desktops_useast"
  location            = data.azurerm_resource_group.rg_useast.location
  resource_group_name = data.azurerm_resource_group.rg_useast.name
  address_space       = ["10.100.0.0/16"]

  tags = {
    environment = "AVD"
  }
}

# Create a default subnet for the East US VNet
resource "azurerm_subnet" "subnet_useast" {
  name                 = "default-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_useast.name
  virtual_network_name = azurerm_virtual_network.vnet_useast.name
  address_prefixes     = ["10.100.0.0/24"]
}

# Create a Public IP for the East US NAT Gateway
resource "azurerm_public_ip" "pip_nat_useast" {
  name                = "pip-nat-useast"
  location            = data.azurerm_resource_group.rg_useast.location
  resource_group_name = data.azurerm_resource_group.rg_useast.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1]
}

# Create the East US NAT Gateway
resource "azurerm_nat_gateway" "nat_gw_useast" {
  name                = "nat-gateway-useast"
  location            = data.azurerm_resource_group.rg_useast.location
  resource_group_name = data.azurerm_resource_group.rg_useast.name
  sku_name            = "Standard"
}

# Associate the Public IP with the East US NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "assoc_pip_nat_useast" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw_useast.id
  public_ip_address_id = azurerm_public_ip.pip_nat_useast.id
}

# Associate the subnet with the East US NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "assoc_subnet_nat_useast" {
  subnet_id      = azurerm_subnet.subnet_useast.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw_useast.id
}


#---------------------------------------------------
# West US Network Resources
#---------------------------------------------------

# Look up the existing West US Resource Group
data "azurerm_resource_group" "rg_uswest" {
  name = "virtual_desktops_uswest"
}

# Create the West US Virtual Network in the existing RG
resource "azurerm_virtual_network" "vnet_uswest" {
  name                = "virtual_desktops_uswest"
  location            = data.azurerm_resource_group.rg_uswest.location
  resource_group_name = data.azurerm_resource_group.rg_uswest.name
  address_space       = ["10.101.0.0/16"]

  tags = {
    environment = "AVD"
  }
}

# Create a default subnet for the West US VNet
resource "azurerm_subnet" "subnet_uswest" {
  name                 = "default-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_uswest.name
  virtual_network_name = azurerm_virtual_network.vnet_uswest.name
  address_prefixes     = ["10.101.0.0/24"]
}

# Create a Public IP for the West US NAT Gateway
resource "azurerm_public_ip" "pip_nat_uswest" {
  name                = "pip-nat-uswest"
  location            = data.azurerm_resource_group.rg_uswest.location
  resource_group_name = data.azurerm_resource_group.rg_uswest.name
  allocation_method   = "Static"
  sku                 = "Standard"
#  zones               = [1]
}

# Create the West US NAT Gateway
resource "azurerm_nat_gateway" "nat_gw_uswest" {
  name                = "nat-gateway-uswest"
  location            = data.azurerm_resource_group.rg_uswest.location
  resource_group_name = data.azurerm_resource_group.rg_uswest.name
  sku_name            = "Standard"
}

# Associate the Public IP with the West US NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "assoc_pip_nat_uswest" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw_uswest.id
  public_ip_address_id = azurerm_public_ip.pip_nat_uswest.id
}

# Associate the subnet with the West US NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "assoc_subnet_nat_uswest" {
  subnet_id      = azurerm_subnet.subnet_uswest.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw_uswest.id
}

#---------------------------------------------------
# Global AVD RDP Properties
#---------------------------------------------------

# Define the custom RDP properties in one place to reuse them
locals {
  custom_rdp_properties = "targetisaadjoined:i:1;drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:0;devicestoredirect:s:;redirectcomports:i:1;redirectsmartcards:i:1;usbdevicestoredirect:s:;enablecredsspsupport:i:1;redirectwebauthn:i:1;use multimon:i:1;autoreconnection enabled:i:1;audiocapturemode:i:1;encode redirected video capture:i:1;redirected video capture encoding quality:i:1;camerastoredirect:s:*;enablerdsaadauth:i:1"
}

#---------------------------------------------------
# East US AVD Resources
#---------------------------------------------------

# Look up the existing East US Resource Group
data "azurerm_resource_group" "rg_useast_avd" {
  name = "virtual_desktops_useast"
}

#---------------------------------------------------
# East US AVD Resources
#---------------------------------------------------

# Look up the existing East US Resource Group
data "azurerm_resource_group" "rg_useast_avd_lookup" {
  name = "virtual_desktops_useast"
}

# Create the East US Host Pool
resource "azurerm_virtual_desktop_host_pool" "hp_useast" {
  name                         = "USEast_Personal_Hosts"
  location                     = data.azurerm_resource_group.rg_useast.location
  resource_group_name          = data.azurerm_resource_group.rg_useast.name
  type                         = "Personal"
  personal_desktop_assignment_type = "Direct"
  load_balancer_type           = "Persistent"
  custom_rdp_properties        = local.custom_rdp_properties
} 

# Create Application Groups

# Create the explicit Desktop Application Group for the East US Host Pool
resource "azurerm_virtual_desktop_application_group" "dag_useast" {
  name                = "USEast_Personal_Hosts-DAG"
  location            = data.azurerm_resource_group.rg_useast.location
  resource_group_name = data.azurerm_resource_group.rg_useast.name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.hp_useast.id
  default_desktop_display_name = "US East" 
}

# Create the East US Workspace
resource "azurerm_virtual_desktop_workspace" "ws_useast" {

  name                = "US_East_Personal_Hosts"
  friendly_name       = "US East Personal Hosts"
  location            = data.azurerm_resource_group.rg_useast.location
  resource_group_name = data.azurerm_resource_group.rg_useast.name
}

# Associate the new Application Group with the workspace
resource "azurerm_virtual_desktop_workspace_application_group_association" "assoc_useast" {
  workspace_id         = azurerm_virtual_desktop_workspace.ws_useast.id
  application_group_id = azurerm_virtual_desktop_application_group.dag_useast.id
}

#---------------------------------------------------
# West US AVD Resources
#---------------------------------------------------

# Look up the existing West US Resource Group
data "azurerm_resource_group" "rg_uswest_avd" {
  name = "virtual_desktops_uswest"
}

# Create the West US Host Pool
resource "azurerm_virtual_desktop_host_pool" "hp_uswest" {
  name                         = "USWest_Personal_Hosts"
  location                     = data.azurerm_resource_group.rg_uswest.location
  resource_group_name          = data.azurerm_resource_group.rg_uswest.name
  type                         = "Personal"
  personal_desktop_assignment_type = "Direct"
  load_balancer_type           = "Persistent"
  custom_rdp_properties        = local.custom_rdp_properties
}

# Create the explicit Desktop Application Group for the West US Host Pool
resource "azurerm_virtual_desktop_application_group" "dag_uswest" {
  name                = "USWest_Personal_Hosts-DAG"
  location            = data.azurerm_resource_group.rg_uswest.location
  resource_group_name = data.azurerm_resource_group.rg_uswest.name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.hp_uswest.id
  #friendly_name	      = "US West"
  default_desktop_display_name = "US West" 
}

# Create the West US Workspace
resource "azurerm_virtual_desktop_workspace" "ws_uswest" {

  name                = "US_West_Personal_Hosts"
  friendly_name       = "US West Personal Hosts"
  location            = data.azurerm_resource_group.rg_uswest.location
  resource_group_name = data.azurerm_resource_group.rg_uswest.name
}

# Associate the new Application Group with the workspace
resource "azurerm_virtual_desktop_workspace_application_group_association" "assoc_uswest" {
  workspace_id         = azurerm_virtual_desktop_workspace.ws_uswest.id
  application_group_id = azurerm_virtual_desktop_application_group.dag_uswest.id
}
