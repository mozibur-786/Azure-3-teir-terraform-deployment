# Azure Database for MySQL Flexible Server with public access and VNet private access.
# Azure does not allow VNet-injected Flexible Servers to also have a public endpoint,
# so this module uses public access plus Private Endpoint for VNet connectivity.

resource "azurerm_mysql_flexible_server" "main" {
  name                   = "${var.project_name}-mysql-flex"
  location               = var.azure_location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.db_username
  administrator_password = var.db_password
  backup_retention_days  = var.backup_retention_days
  sku_name               = var.sku_name
  version                = var.mysql_version

  storage {
    size_gb = var.allocated_storage
  }

  dynamic "high_availability" {
    for_each = var.multi_az ? [1] : []
    content {
      mode = "ZoneRedundant"
    }
  }

  tags = {
    Name = "${var.project_name}-mysql"
  }
}
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = var.require_secure_transport
}
resource "azurerm_mysql_flexible_database" "main" {
  name                = var.db_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "public" {
  for_each = var.public_firewall_rules

  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = each.value.start_ip_address
  end_ip_address      = each.value.end_ip_address
}

resource "azurerm_private_dns_zone" "mysql" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = {
    Name = "${var.project_name}-mysql-private-dns-zone"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "mysql" {
  name                  = "${var.project_name}-mysql-dns-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.mysql.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_endpoint" "mysql" {
  name                = "${var.project_name}-mysql-pe"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.project_name}-mysql-psc"
    private_connection_resource_id = azurerm_mysql_flexible_server.main.id
    subresource_names              = ["mysqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${var.project_name}-mysql-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.mysql.id]
  }

  tags = {
    Name = "${var.project_name}-mysql-pe"
  }
}
