# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.15.0"
    }
  }
}

# Configure the Azure Active Directory Provider
provider "azuread" {
}


# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}
