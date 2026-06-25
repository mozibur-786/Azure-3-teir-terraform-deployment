variable "azure_location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "project_name" {
  type    = string
  default = "three-tier"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "subnet_id" {
  type = string
}

variable "nsg_id" {
  type = string
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "custom_image_id" {
  description = "Azure managed image ID for backend VMSS instances"
  type        = string
}

variable "backend_address_pool_ids" {
  description = "Application Gateway backend pool IDs for backend VMSS instances."
  type        = list(string)
  default     = []
}

variable "lb_backend_pool_id" {
  description = "Application Gateway backend pool ID for backend VMSS instances."
  type        = string
}

variable "health_probe_id" {
  description = "Deprecated. Application Gateway health is configured on the gateway, not the VMSS."
  type        = string
  default     = null
}

variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 3
}

variable "scale_out_cpu_threshold" {
  type    = number
  default = 80
}
