output "webapp_name" {
  value = local.webapp_name
}
output "scm_user" {
  sensitive = true
  value = jsondecode(data.azapi_resource_action.credentials.output).properties.publishingUserName
}
output "scm_password" {
  sensitive = true
  value = jsondecode(data.azapi_resource_action.credentials.output).properties.publishingPassword
}
