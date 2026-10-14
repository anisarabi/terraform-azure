terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.92.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "6912d7a0-bc28-459a-9407-33bbba641c07"
  client_id       = "230411ec-45e9-4650-95b2-7675131e2d1a"
  client_secret   = "8D~7Q~y39tBTXsFXGcuVIwvGCOorRUo6dXtwX"
  tenant_id       = "70c0f6d9-7f3b-4425-a6b6-09b47643ec58"
  features {}
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "terraformstore10090"
}

locals {
  resource_group_name = "app-grp"
  location            = "North Europe"
} 

resource "azurerm_resource_group" "app_grp"{
  name="app-grp" 
  location=local.location
}

# Here we are creating a storage account.
# The storage account service has more properties and hence there are more arguements we can specify here

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = local.resource_group_name
  location                 = local.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = true
  depends_on=[azurerm_resource_group.app_grp]
}

# Here we are creating a container in the storage account
resource "azurerm_storage_container" "data" {
  name                  = "data"
  storage_account_name  = var.storage_account_name
  container_access_type = "private"
  Depends_on=[azurerm_storage_account.storage_account]
}

# This is used to upload a local file onto the container
resource "azurerm_storage_blob" "sample" {
  name                   = "sample.txt"
  storage_account_name   = var.storage_account_name
  storage_container_name = "data"
  type                   = "Block"
  source                 = "sample.txt"
  # Here we we are adding a dependency. The file can only be uploaded if the container is present
# We can access the attributes of a resource in terraform via the resource_type.resource_name

  depends_on=[azurerm_storage_container.data]

}
