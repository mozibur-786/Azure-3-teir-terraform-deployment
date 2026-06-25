output "app_gateway_id" {
  value = azurerm_application_gateway.backend.id
}

output "app_gateway_public_ip" {
  value = azurerm_public_ip.backend_pip.ip_address
}

output "backend_address_pool_id" {
  value = tolist(azurerm_application_gateway.backend.backend_address_pool)[0].id
}

output "lb_public_ip" {
  value = azurerm_public_ip.backend_pip.ip_address
}
