resource "azapi_resource" "webhook" {
  type = "Microsoft.ContainerRegistry/registries/webhooks@2023-11-01-preview"
  name = "webappapp${var.product_name}frontend${var.tags.environment}"
  parent_id = var.registry_id
  location = var.location
  tags = var.tags
  body = jsonencode({
    properties = {
      actions = ["push"]
      scope = var.repository_name
      serviceUri = "https://${var.scm_user}:${var.scm_password}@${var.webapp_name}.scm.azurewebsites.net/api/registry/webhook"
      status = "enabled"
    }
  })
}
