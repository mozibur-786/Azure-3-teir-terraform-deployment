output "backend_vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.backend.id
}

output "backend_vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.backend.name
}
