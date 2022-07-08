# Create a resource group
resource "azurerm_resource_group" "TerraformRGPOC" {
  name     = var.rg-name
  location = var.rg-location
}

data "azurerm_client_config" "current" {}

# # Create a virtual network within the resource group
resource "azurerm_virtual_network" "TerraformPOCVnet" {
  name                = var.vnet-name
  location            = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = var.environment
  }
}

#Virtual Machine
resource "azurerm_subnet" "TerraformPOCSubnetVM" {
  name                 = var.subnet-vm-name
  resource_group_name  = azurerm_resource_group.TerraformRGPOC.name
  virtual_network_name = azurerm_virtual_network.TerraformPOCVnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "TerraformPOCNetworkInterface" {
  name                = var.nic-vm-name
  location            = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name

  ip_configuration {
    name                          = var.nic-vm-name
    subnet_id                     = azurerm_subnet.TerraformPOCSubnetVM.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = var.environment
  }
}

resource "azurerm_linux_virtual_machine" "TerraformPOCLinuxVM" {
  name                = var.vm-linux-name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  location            = azurerm_resource_group.TerraformRGPOC.location
  size                = var.vm-linux-size
  admin_username      = var.vm-linux-adminuser
  network_interface_ids = [
    azurerm_network_interface.TerraformPOCNetworkInterface.id,
  ]

  admin_ssh_key {
    username   = var.vm-linux-adminuser
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm-linux-replicationtype
  }

   source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  zone = "1"
  tags = {
    environment = var.environment
  }
}

data "azurerm_virtual_machine" "TerraformPOCLinuxVMData" {
  name                = azurerm_linux_virtual_machine.TerraformPOCLinuxVM.name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
}

data "azurerm_storage_account" "TerraformRGStorageAccountData" {
  name                = azurerm_storage_account.TerraformRGStorageAccount.name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
}

#Enabling Diagnostic setting
resource "azurerm_monitor_diagnostic_setting" "TerraformPOCDiagnosticSetting" {
  name               = var.vm-diagnosticsetting-name
 target_resource_id = data.azurerm_virtual_machine.TerraformPOCLinuxVMData.id
  storage_account_id = data.azurerm_storage_account.TerraformRGStorageAccountData.id

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

# #Key Vault
resource "azurerm_key_vault" "TerraformRGKeyVault" {
  name                        = var.keyvault-name
  location                    = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name         = azurerm_resource_group.TerraformRGPOC.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    storage_permissions = [
      "Get",
    ]
  }

  tags = {
    environment = var.environment
  }
}



#Storage Account
resource "azurerm_storage_account" "TerraformRGStorageAccount" {
  name                     = var.storageaccount-name
  resource_group_name      = azurerm_resource_group.TerraformRGPOC.name
  location                 = azurerm_resource_group.TerraformRGPOC.location
  account_tier             = var.storageaccount-accounttier
  account_replication_type = var.storageaccount-replicationtype
  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "TerraformRGStorageAccountContainer" {
  name                  = var.storageaccount-container-name
  storage_account_name  = azurerm_storage_account.TerraformRGStorageAccount.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "TerraformRGStorageAccountContainer2" {
  name                  = "test"
  storage_account_name  = azurerm_storage_account.TerraformRGStorageAccount.name
  container_access_type = "private"
}

# Retrieving and Reading the sas URL
data "azurerm_storage_account_blob_container_sas" "TerraformRGStorageAccountContainerBlob" {
  connection_string = azurerm_storage_account.TerraformRGStorageAccount.primary_connection_string
  container_name    = azurerm_storage_container.TerraformRGStorageAccountContainer.name
  https_only        = true

  ip_address = "168.1.5.65"

  start  = "2022-03-21"
  expiry = "2023-12-21"

  permissions {
    read   = true
    add    = true
    create = false
    write  = false
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}




#Backup and recovery
resource "azurerm_recovery_services_vault" "TerraformPOCRecoveryServicesVault" {
  name                = var.recovery-vault-name
  location            = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  sku                 = "Standard"
}

resource "azurerm_backup_policy_vm" "TerraformPOCRecoveryServicesVaultVMPolicy" {
  name                = var.backup-policy-name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  recovery_vault_name = azurerm_recovery_services_vault.TerraformPOCRecoveryServicesVault.name

  timezone = "UTC"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 10
  }

  retention_weekly {
    count    = 42
    weekdays = ["Sunday", "Wednesday", "Friday", "Saturday"]
  }

  retention_monthly {
    count    = 7
    weekdays = ["Sunday", "Wednesday"]
    weeks    = ["First", "Last"]
  }

  retention_yearly {
    count    = 77
    weekdays = ["Sunday"]
    weeks    = ["Last"]
    months   = ["January"]
  }
}

#Log analytics and App insights
resource "azurerm_log_analytics_workspace" "TerraformPOCLogAnalyticsWorkspace" {
  name                = var.loganalytics-name
  location            = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = var.environment
  }
}

resource "azurerm_application_insights" "TerraformPOCAppInsights" {
  name                = var.appinsights-name
  location            = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  workspace_id        = azurerm_log_analytics_workspace.TerraformPOCLogAnalyticsWorkspace.id
  application_type    = "web"
  tags = {
    environment = var.environment
  }
}



#App Service with Jboss
resource "azurerm_service_plan" "TerraformPOCAppServicePlan" {
  name                = "terraformpoc-appserviceplan"
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  location            = azurerm_resource_group.TerraformRGPOC.location
  os_type             = "Linux"
  sku_name            = "B1"
  tags = {
    environment = var.environment
  }
}

data "azurerm_service_plan" "TerraformPOCAppServicePlanData" {
  name                = azurerm_service_plan.TerraformPOCAppServicePlan.name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
}

resource "azurerm_linux_web_app" "TerraformPOCAppServiceLinux" {
  name                = var.appservice-name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
  location            = azurerm_resource_group.TerraformRGPOC.location
  service_plan_id     = data.azurerm_service_plan.TerraformPOCAppServicePlanData.id
  site_config {
  
}

tags = {
    environment = var.environment
  }
}

data "azurerm_linux_web_app" "TerraformPOCAppServiceLinuxData" {
  name                = azurerm_linux_web_app.TerraformPOCAppServiceLinux.name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name
}

## PostGre SQL
resource "azurerm_subnet" "TerraformPOCSubnetDB" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.TerraformRGPOC.name
  virtual_network_name = azurerm_virtual_network.TerraformPOCVnet.name
 # security_group = azurerm_network_security_group.TerraformPOCNSG.id
  address_prefixes     = ["10.0.3.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

#Network Security Group
resource "azurerm_network_security_group" "TerraformPOCNSGDB" {
  name                = var.nsgdb-name
  location            = azurerm_resource_group.TerraformRGPOC.location
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name

   security_rule {
    name                       = "Allow All"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "TerraformPOCNSGAssociationDB" {
  subnet_id                 = azurerm_subnet.TerraformPOCSubnetDB.id
  network_security_group_id = azurerm_network_security_group.TerraformPOCNSGDB.id
}

resource "azurerm_private_dns_zone" "TerraformPOCPrivateDNSZone" {
  name                = var.privatednszone-name
  resource_group_name = azurerm_resource_group.TerraformRGPOC.name

  depends_on = [azurerm_subnet_network_security_group_association.TerraformPOCNSGAssociationDB]
}

resource "azurerm_private_dns_zone_virtual_network_link" "TerraformPOCPrivateDNSZoneVirtualNetworkLink" {
  name                  = var.privatednszonevnetlink-name
  private_dns_zone_name = azurerm_private_dns_zone.TerraformPOCPrivateDNSZone.name
  virtual_network_id    = azurerm_virtual_network.TerraformPOCVnet.id
  resource_group_name   = azurerm_resource_group.TerraformRGPOC.name
}

resource "azurerm_postgresql_flexible_server" "TerraformPOCPostgreDatabase" {
  name                   = var.postgre-name
  resource_group_name    = azurerm_resource_group.TerraformRGPOC.name
  location               = azurerm_resource_group.TerraformRGPOC.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.TerraformPOCSubnetDB.id
  private_dns_zone_id    = azurerm_private_dns_zone.TerraformPOCPrivateDNSZone.id
  administrator_login    = var.postgre-adminuser
  administrator_password = var.postgre-password
  zone                   = "1"

  storage_mb = 32768

  sku_name   = var.postgre-sku
  backup_retention_days  = 7
  depends_on = [azurerm_private_dns_zone_virtual_network_link.TerraformPOCPrivateDNSZoneVirtualNetworkLink]

}




