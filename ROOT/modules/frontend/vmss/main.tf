# ─────────────────────────────────────────────────────
# Frontend VMSS  (AWS ASG + Launch Template equivalent)
# Azure VMSS handles both scaling AND the instance template
# ─────────────────────────────────────────────────────

resource "azurerm_linux_virtual_machine_scale_set" "frontend" {
  name                = "${var.project_name}-frontend-vmss"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  sku                 = var.vm_size
  instances           = var.desired_capacity
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  disable_password_authentication = false

  upgrade_mode = "Manual"

  source_image_id = var.custom_image_id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "frontend-vmss-nic"
    primary = true

    ip_configuration {
      name                                         = "frontend-vmss-ipconfig"
      primary                                      = true
      subnet_id                                    = var.subnet_id
      application_gateway_backend_address_pool_ids = var.backend_address_pool_ids
    }

    network_security_group_id = var.nsg_id
  }

  tags = { Name = "${var.project_name}-frontend-vmss" }
}

# ─────────────────────────────────────────────────────
# Autoscale Settings  (AWS ASG scaling policy equivalent)
# ─────────────────────────────────────────────────────
resource "azurerm_monitor_autoscale_setting" "frontend" {
  name                = "${var.project_name}-frontend-autoscale"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.frontend.id

  profile {
    name = "cpu-autoscale"

    capacity {
      default = var.desired_capacity
      minimum = var.min_size
      maximum = var.max_size
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.frontend.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_cpu_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.frontend.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 20
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
