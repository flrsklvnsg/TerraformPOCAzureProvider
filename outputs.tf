output "resource_group_name" {
    value = azurerm_resource_group.TerraformRGPOC.name
}

output "virtual_machine_name" {
  value = data.azurerm_virtual_machine.TerraformPOCLinuxVMData.name
}

output "virtual_machine_id" {
  value = data.azurerm_virtual_machine.TerraformPOCLinuxVMData.id
}

output "sas_url_query_string" {
  value = data.azurerm_storage_account_blob_container_sas.TerraformRGStorageAccountContainerBlob.sas
  sensitive = true
}

output "AppServicePlanName" {
  value = data.azurerm_service_plan.TerraformPOCAppServicePlanData.name
}
output "AppServicePlanId" {
  value = data.azurerm_service_plan.TerraformPOCAppServicePlanData.id
}
output "LinuxWebAppName" {
  value = data.azurerm_linux_web_app.TerraformPOCAppServiceLinuxData.name
}
output "LinuxWebAppId" {
  value = data.azurerm_linux_web_app.TerraformPOCAppServiceLinuxData.id
}

output "instrumentation_key" {
  value = azurerm_application_insights.TerraformPOCAppInsights.instrumentation_key
  sensitive = true
}

output "app_id" {
  value = azurerm_application_insights.TerraformPOCAppInsights.app_id
}