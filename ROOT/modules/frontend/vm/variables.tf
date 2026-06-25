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
