variable "azure_location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name prefix used for resource naming"
  type        = string
  default     = "three-tier"
}

variable "resource_group_name" {
  description = "Existing Azure resource group name"
  type        = string
  default     = "three-tier-rg"
}

variable "vnet_cidr" {
  description = "CIDR block for the VNet"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

# Public Subnets
variable "public_subnet_1_cidr" { type = string }
variable "public_subnet_2_cidr" { type = string }

# Dedicated Application Gateway Subnets
variable "frontend_gateway_subnet_cidr" { type = string }
variable "backend_gateway_subnet_cidr" { type = string }

# Private Web Subnets
variable "private_subnet_1_cidr" { type = string }
variable "private_subnet_2_cidr" { type = string }

# Private App Subnets
variable "private_subnet_3_cidr" { type = string }
variable "private_subnet_4_cidr" { type = string }

# Private DB Subnets
variable "private_subnet_5_cidr" { type = string }
variable "private_subnet_6_cidr" { type = string }
