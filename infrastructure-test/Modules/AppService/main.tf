locals {
  webapp_name = "app-${var.product_name}-frontend-${var.tags.environment}"
}

resource "azapi_resource" "app_service_plan" {
  type      = "Microsoft.Web/serverfarms@2022-09-01"
  name      = "asp-${var.product_name}-${var.tags.environment}"
  location  = var.location
  parent_id = var.resource_group_id
  tags      = var.tags
  body = jsonencode(
    {
      properties = {
        reserved = true
      }
      sku = {
        name = "B1"
      }
      kind = "linux"
    }
  )
}

resource "azapi_resource" "frontend" {
  type      = "Microsoft.Web/sites@2022-09-01"
  name      = local.webapp_name
  parent_id = var.resource_group_id
  location  = var.location
  tags      = var.tags
  body = jsonencode(
    {
      properties = {
        reserved     = true
        serverFarmId = "${azapi_resource.app_service_plan.id}"
        siteConfig = {
          cors = {
            allowedOrigins = ["*"]
          }
          alwaysOn = true
          appSettings = [{
            name  = "DOCKER_REGISTRY_SERVER_URL"
            value = var.registry_url
            },
            {
              name  = "DOCKER_REGISTRY_SERVER_USERNAME"
              value = var.registry_user
            },
            {
              name  = "DOCKER_REGISTRY_SERVER_PASSWORD"
              value = var.registry_password
            },
            {
              name  = "WEBSITES_ENABLE_APP_SERVICE_STORAGE"
              value = "false"
            },
          ]
          linuxFxVersion = "DOCKER|crapigentest.azurecr.io/nginx:latest"
        }
      }
    }
  )
}

resource "azapi_update_resource" "frontend_config" {
  type      = "Microsoft.Web/sites/config@2022-09-01"
  name      = "logs"
  parent_id = azapi_resource.frontend.id
  body = jsonencode(
    {
      properties = {
        httpLogs = {
          fileSystem = {
            enabled = true
          }
        }
      }
    }
  )
}

# resource "azapi_resource" "credentials" {
#   type = "Microsoft.Web/sites/config@2022-09-01"
#   name = "pushsettings"
#   parent_id = azapi_resource.frontend.id
#   body = jsonencode({})
# }

data "azapi_resource_action" "credentials" {
  type                   = "Microsoft.Web/sites@2024-04-01"
  action                 = "config/publishingcredentials/list"
  method                 = "POST"
  resource_id            = azapi_resource.frontend.id
  response_export_values = ["*"]
}


# │ `name`'s value `app-apigen-frontend-test/publishingCredentials` is invalid. The supported values are [backup, connectionstrings, metadata, pushsettings, slotConfigNames, authsettingsV2, web, logs, appsettings, authsettings, azurestorageaccounts]. Do you mean `logs`? 
# │  You can try to update `azapi` provider to the latest version o