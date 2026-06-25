
# ─────────────────────────────────────────────────────
# FRONTEND VMSS  (AWS Frontend ASG + Launch Template)
# ─────────────────────────────────────────────────────
module "frontend_vmss" {
  source = "../../modules/frontend/vmss"

  azure_location           = module.network.resource_group_location
  resource_group_name      = module.network.resource_group_name
  project_name             = "books-three-tier"
  vm_size                  = local.vmss_size
  subnet_id                = module.network.private_web_subnets[0]
  nsg_id                   = module.network.frontend_server_nsg_id
  admin_username           = "azureuser"
  admin_password           = var.vm_admin_password
  backend_address_pool_ids = [module.frontend_lb.backend_address_pool_id]
  health_probe_id          = null
  desired_capacity         = 1
  min_size                 = 1
  max_size                 = 3
  scale_out_cpu_threshold  = 80
  custom_image_id          = var.frontend_vmss_image_id
}

# ─────────────────────────────────────────────────────
# BACKEND VMSS  (AWS Backend ASG + Launch Template)
# ─────────────────────────────────────────────────────
module "backend_vmss" {
  source = "../../modules/backend/vmss"

  azure_location          = module.network.resource_group_location
  resource_group_name     = module.network.resource_group_name
  project_name            = "books-three-tier"
  vm_size                 = local.vmss_size
  subnet_id               = module.network.private_app_subnets[0]
  nsg_id                  = module.network.backend_server_nsg_id
  admin_username          = "azureuser"
  admin_password          = var.vm_admin_password
  lb_backend_pool_id      = module.backend_lb.backend_address_pool_id
  health_probe_id         = null
  desired_capacity        = 1
  min_size                = 1
  max_size                = 3
  scale_out_cpu_threshold = 80
  custom_image_id         = var.backend_vmss_image_id
}
