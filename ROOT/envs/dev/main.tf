terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id            = var.subscription_id
  skip_provider_registration = true

  # Set ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID
  # via environment variables or Azure CLI login
}

locals {
  vmss_size = "Standard_DS1_v2"
}

# ─────────────────────────────────────────────────────
# NETWORKING  (AWS VPC + Security Groups)
# ─────────────────────────────────────────────────────
module "network" {
  source = "../../modules/infrastructure"

  azure_location      = "eastus"
  project_name        = "three-tier"
  resource_group_name = var.resource_group_name
  vnet_name           = "prod-vnet"
  vnet_cidr           = "10.0.0.0/16"

  public_subnet_1_cidr         = "10.0.1.0/24"
  public_subnet_2_cidr         = "10.0.2.0/24"
  frontend_gateway_subnet_cidr = "10.0.9.0/24"
  backend_gateway_subnet_cidr  = "10.0.10.0/24"
  private_subnet_1_cidr        = "10.0.3.0/24"
  private_subnet_2_cidr        = "10.0.4.0/24"
  private_subnet_3_cidr        = "10.0.5.0/24"
  private_subnet_4_cidr        = "10.0.6.0/24"
  private_subnet_5_cidr        = "10.0.7.0/24"
  private_subnet_6_cidr        = "10.0.8.0/24"
}


# ─────────────────────────────────────────────────────
# BASTION HOST  (AWS EC2 Bastion)
# ─────────────────────────────────────────────────────
module "bastion" {
  source = "../../modules/bastion"

  azure_location      = module.network.resource_group_location
  resource_group_name = module.network.resource_group_name
  project_name        = "three-tier"
  vm_size             = "Standard_B1s"
  subnet_id           = module.network.public_subnets[0]
  nsg_id              = module.network.bastion_nsg_id
  admin_username      = "azureuser"
  admin_password      = var.vm_admin_password
}

# ─────────────────────────────────────────────────────
# FRONTEND VM  (AWS EC2 frontend — source for VMSS image)
# ─────────────────────────────────────────────────────
module "frontend_vm" {
  source = "../../modules/frontend/vm"

  azure_location      = module.network.resource_group_location
  resource_group_name = module.network.resource_group_name
  project_name        = "three-tier"
  vm_size             = "Standard_B1s"
  subnet_id           = module.network.public_subnets[0]
  nsg_id              = module.network.frontend_server_nsg_id
  admin_username      = "azureuser"
  admin_password      = var.vm_admin_password
}

# ─────────────────────────────────────────────────────
# BACKEND VM  (AWS EC2 backend — source for VMSS image)
# ─────────────────────────────────────────────────────
module "backend_vm" {
  source = "../../modules/backend/vm"

  azure_location      = module.network.resource_group_location
  resource_group_name = module.network.resource_group_name
  project_name        = "three-tier"
  vm_size             = "Standard_B1s"
  subnet_id           = module.network.public_subnets[0]
  nsg_id              = module.network.backend_server_nsg_id
  admin_username      = "azureuser"
  admin_password      = var.vm_admin_password


}


# ─────────────────────────────────────────────────────
# DATABASE  (AWS RDS MySQL → Azure MySQL Flexible Server)
# ─────────────────────────────────────────────────────
module "database" {
  source = "../../modules/database"

  azure_location             = module.network.resource_group_location
  resource_group_name        = module.network.resource_group_name
  project_name               = "three-tier"
  db_name                    = "bookdb"
  db_username                = "adminuser"
  db_password                = var.db_password # Pass via tfvars or env var, never hardcode
  allocated_storage          = 20
  mysql_version              = "8.0.21"
  sku_name                   = "B_Standard_B1ms"
  multi_az                   = false
  vnet_id                    = module.network.vnet_id
  private_endpoint_subnet_id = module.network.private_app_subnets[0]
  require_secure_transport = "OFF"

  # Public MySQL access. Replace this wide-open rule with your trusted IP/CIDR for production.
  public_firewall_rules = {
    allow_all_public = {
      start_ip_address = "0.0.0.0"
      end_ip_address   = "255.255.255.255"
    }
  }
}

# ─────────────────────────────────────────────────────
# BACKEND APPLICATION GATEWAY  (AWS Backend ALB)
# ─────────────────────────────────────────────────────
module "backend_lb" {
  source = "../../modules/backend/loadbalancer"

  azure_location      = module.network.resource_group_location
  resource_group_name = module.network.resource_group_name
  gateway_name        = "backend-agw"
  gateway_subnet_id   = module.network.backend_gateway_subnet_id
}

# ─────────────────────────────────────────────────────
# FRONTEND APPLICATION GATEWAY  (AWS Frontend ALB)
# ─────────────────────────────────────────────────────
module "frontend_lb" {
  source = "../../modules/frontend/loadbalancer"

  azure_location      = module.network.resource_group_location
  resource_group_name = module.network.resource_group_name
  alb_name            = "frontend-agw"
  gateway_subnet_id   = module.network.frontend_gateway_subnet_id
}



