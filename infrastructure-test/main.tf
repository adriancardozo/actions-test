terraform {
  required_version = "1.11.2"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "1.10.0"
    }
  }
}

provider "azapi" {
  skip_provider_registration = true
}

locals {
  environment = "test"
}

locals {
  tags = {
    environment = "test"
  }
  resource_group_id = "/subscriptions/76760cd7-cfab-49d8-8eb4-5ea7aea4b076/resourceGroups/api-gen-prueba"
  location = "eastus"
  product_name = "apigen"
  subscription_id = "76760cd7-cfab-49d8-8eb4-5ea7aea4b076"
  repository_name = "nginx"
  registry_id = "/subscriptions/76760cd7-cfab-49d8-8eb4-5ea7aea4b076/resourceGroups/api-gen-prueba/providers/Microsoft.ContainerRegistry/registries/crapigentest"
  registry_url = "https://crapigentest.azurecr.io"
  registry_user = "crapigentest"
  registry_password = "VAc4JJPVas7QZEMDIohI9AFyAmJYZzo8a7gc0O1fFP+ACRCXFf1W"
}

module "AppServices" {
  source               = "./Modules/AppService"
  tags                 = local.tags
  resource_group_id    = local.resource_group_id
  location             = local.location
  product_name         = local.product_name
  registry_url         = local.registry_url
  registry_user        = local.registry_user
  registry_password    = local.registry_password
}

module "ContainerRegistry" {
  source            = "./Modules/ContainerRegistry"
  resource_group_id = local.resource_group_id
  tags              = local.tags
  product_name      = local.product_name
  environment       = local.environment
  location          = local.location
  webapp_name       = module.AppServices.webapp_name
  registry_id       = local.registry_id
  repository_name   = local.repository_name
  scm_user          = module.AppServices.scm_user
  scm_password      = module.AppServices.scm_password
}
