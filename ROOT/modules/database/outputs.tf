output "mysql_server_id" {
  value = azurerm_mysql_flexible_server.main.id
}

output "mysql_fqdn" {
  value = azurerm_mysql_flexible_server.main.fqdn
}

output "database_name" {
  value = azurerm_mysql_flexible_database.main.name
}

output "private_endpoint_id" {
  value = azurerm_private_endpoint.mysql.id
}

output "private_dns_zone_id" {
  value = azurerm_private_dns_zone.mysql.id
}
