variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string

}


variable "subscription_id" {
  description = "Azure Subscription ID to deploy resources into"
  type        = string
}


variable "vm_admin_password" {
  description = "Admin password for Linux VM and VMSS access"
  type        = string
  sensitive   = true
}

variable "frontend_vmss_image_id" {
  description = "Azure managed image ID for frontend VMSS"
  type        = string
}

variable "backend_vmss_image_id" {
  description = "Azure managed image ID for backend VMSS"
  type        = string
}

variable "db_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
}
