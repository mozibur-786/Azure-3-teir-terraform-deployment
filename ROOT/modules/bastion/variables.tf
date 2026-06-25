variable "azure_location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "three-tier"
}

variable "vm_size" {
  description = "Azure VM size (AWS instance_type equivalent)"
  type        = string
  default     = "Standard_B1s"
}

variable "subnet_id" {
  description = "Subnet ID for bastion NIC"
  type        = string
}

variable "nsg_id" {
  description = "NSG ID for the bastion NIC"
  type        = string
}

variable "admin_username" {
  description = "Admin username for VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for VM access"
  type        = string
  sensitive   = true
}
