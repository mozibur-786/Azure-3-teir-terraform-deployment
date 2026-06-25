output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "resource_group_location" {
  value = data.azurerm_resource_group.rg.location
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "public_subnets" {
  value = [azurerm_subnet.public_1.id, azurerm_subnet.public_2.id]
}

output "frontend_gateway_subnet_id" {
  value = azurerm_subnet.frontend_gateway.id
}

output "backend_gateway_subnet_id" {
  value = azurerm_subnet.backend_gateway.id
}

output "private_web_subnets" {
  value = [azurerm_subnet.private_web_1.id, azurerm_subnet.private_web_2.id]
}

output "private_app_subnets" {
  value = [azurerm_subnet.private_app_1.id, azurerm_subnet.private_app_2.id]
}

output "private_db_subnet_1_id" {
  value = azurerm_subnet.private_db_1.id
}

output "private_db_subnet_2_id" {
  value = azurerm_subnet.private_db_2.id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.nat.id
}

output "bastion_nsg_id" {
  value = azurerm_network_security_group.bastion.id
}

output "alb_frontend_nsg_id" {
  value = azurerm_network_security_group.alb_frontend.id
}

output "alb_backend_nsg_id" {
  value = azurerm_network_security_group.alb_backend.id
}

output "frontend_server_nsg_id" {
  value = azurerm_network_security_group.frontend_server.id
}

output "backend_server_nsg_id" {
  value = azurerm_network_security_group.backend_server.id
}

output "database_nsg_id" {
  value = azurerm_network_security_group.database.id
}
