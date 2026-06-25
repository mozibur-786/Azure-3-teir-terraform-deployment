output "frontend_vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.frontend.id
}

output "frontend_vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.frontend.name
}
