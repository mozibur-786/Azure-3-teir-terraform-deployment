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

variable "db_username" {
  description = "MySQL administrator login"
  type        = string
}

variable "db_password" {
  description = "MySQL administrator password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Initial database name"
  type        = string
}

variable "allocated_storage" {
  description = "Storage size in GB. Azure minimum is 20."
  type        = number
  default     = 20
}

variable "backup_retention_days" {
  description = "Backup retention days for the MySQL Flexible Server"
  type        = number
  default     = 7
}

variable "mysql_version" {
  description = "MySQL version"
  type        = string
  default     = "8.0.21"
}

variable "sku_name" {
  description = "Azure MySQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "multi_az" {
  description = "Enable zone-redundant high availability"
  type        = bool
  default     = false
}

variable "vnet_id" {
  description = "VNet ID for private DNS zone link"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the MySQL private endpoint will be created"
  type        = string
}

variable "public_firewall_rules" {
  description = "Public firewall rules allowed to reach MySQL. Use trusted IP ranges only."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}
variable "require_secure_transport" {
  type    = string
  default = "ON"
}
