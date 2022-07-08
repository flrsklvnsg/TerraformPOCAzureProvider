variable "environment" {
  type        = string
  description = "Name of the deployment environment"
  default     = "dev"
}
variable "rg-location" {
  type        = string
  description = "Location of the azure resource group."
  default     = "eastasia"
}
variable "rg-name" {
  type        = string
  description = "Name of the azure resource group."
  default     = "Terraform-POC-RG-Dev"
}
variable "vnet-name" {
  type        = string
  description = "Name of the network security group."
  default     = "Dev-Terraform-POC-VNET"
}
variable "subnet-vm-name" {
  type        = string
  description = "Name of the subnet for VM."
  default     = "Terraformpocsubnetvm"  
}
variable "nic-vm-name" {
  type        = string
  description = "Name of the nic for VM."
  default     = "terraformpoc-nic"     
}
#Linux VM Variables
variable "vm-linux-name" {
  type        = string
  description = "Name of the Linux VM."
  default     = "dev-terraformpoc-linux-vm"     
}
variable "vm-linux-location" {
  type        = string
  description = "location of the Linux VM."
  default     = "eastasia"  
}
variable "vm-linux-size" {
  type        = string
  description = "size of the Linux VM."
  default     = "Standard_B1s"     
}
variable "vm-linux-adminuser" {
  type        = string
  description = "Admin username of the Linux VM."
  default     = "adminuser"     
}
variable "vm-linux-replicationtype" {
  type        = string
  description = "Storage account type or replication type username of the Linux VM."
  default     = "Standard_LRS"     
}
#Linux VM Variables

variable "keyvault-name" {
  type        = string
  description = ""
  default     = "terraformpockeyvaultdev"
}

variable "storageaccount-name" {
  type        = string
  description = "Name of the storage account."
  default     = "terraformpocsadev"
}
variable "storageaccount-accounttier" {
  type        = string
  description = ""
  default     = "Standard"
}
variable "storageaccount-replicationtype" {
  type        = string
  description = ""
  default     = "LRS"
}
variable "storageaccount-container-name" {
  type        = string
  description = ""
  default     = "terraformpocsacontainerdev"
}

#Backup, Recovery and Monitoring variables

variable "recovery-vault-name" {
  type        = string
  description = ""
  default     = "dev-terraformpoc-recovery-vault"
}
variable "backup-policy-name" {
  type        = string
  description = ""
  default     = "dev-terraformpoc-recovery-vault"
}

variable "vm-diagnosticsetting-name" {
  type        = string
  description = ""
  default     = "dev-terraformpoc-vm-diagnosticsetting"
}

variable "loganalytics-name" {
  type        = string
  description = "Log analytics name"
  default     = "dev-workspace"
  
}

variable "appinsights-name" {
  type        = string
  description = "app insights name"
  default     = "dev-terraformpoc-linux-appinsights"
  
}

variable "appservice-name" {
  type        = string
  description = "web app name"
  default     = "dev-terraformpoc-linux"
}


variable "nsg-name" {
  type        = string
  description = "Name of the azure resource group."
  default     = "Terraform-POC-NSG-Dev"
}

#Postgre variables
variable "nsgdb-name" {
  type        = string
  description = "Name of the azure resource group."
  default     = "Terraform-POC-NSG-DB-Dev"
}

variable "privatednszone-name" {
  type        = string
  description = "Name of the private dns zone."
  default     = "terraformpocdatabase.postgres.database.azure.com"
}

variable "privatednszonevnetlink-name" {
  type        = string
  description = "Name of the private dns zone."
  default     = "TerraformPocDatabaseVnetZone.com"
}

variable "postgre-name" {
  type        = string
  description = "Name of the postgre for azure."
  default     = "terraformpocdatabase-psqlflexibleserver"
}

variable "postgre-adminuser" {
  type        = string
  description = "admin user of the postgre for azure."
  default     = "psqladmin"
}

variable "postgre-password" {
  type        = string
  description = "password of the postgre for azure."
  default     = "H@Sh1CoR3!"
}

variable "postgre-sku" {
  type        = string
  description = "Name of the postgre for azure."
  default     = "B_Standard_B1ms"
}





