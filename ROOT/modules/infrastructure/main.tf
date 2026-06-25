# ─────────────────────────────────────────────────────
# RESOURCE GROUP
# ─────────────────────────────────────────────────────
# Resource group creation is disabled because the resource group already exists.
# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.azure_location
#
#   tags = {
#     Name    = var.resource_group_name
#     Project = var.project_name
#   }
# }

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# ─────────────────────────────────────────────────────
# VIRTUAL NETWORK  (AWS VPC equivalent)
# ─────────────────────────────────────────────────────
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = [var.vnet_cidr]

  tags = {
    Name = var.vnet_name
  }
}

# ─────────────────────────────────────────────────────
# SUBNETS
# ─────────────────────────────────────────────────────

# Public Subnets (for ALB / Bastion)
resource "azurerm_subnet" "public_1" {
  name                 = "${var.vnet_name}-public-subnet-1"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_1_cidr]
}

resource "azurerm_subnet" "public_2" {
  name                 = "${var.vnet_name}-public-subnet-2"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnet_2_cidr]
}

# Dedicated Application Gateway subnets
resource "azurerm_subnet" "frontend_gateway" {
  name                 = "${var.vnet_name}-frontend-gateway"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.frontend_gateway_subnet_cidr]
}

resource "azurerm_subnet" "backend_gateway" {
  name                 = "${var.vnet_name}-backend-gateway"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.backend_gateway_subnet_cidr]
}

# Private Web Subnets (frontend VMSS)
resource "azurerm_subnet" "private_web_1" {
  name                 = "${var.vnet_name}-private-web-1"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_1_cidr]
}

resource "azurerm_subnet" "private_web_2" {
  name                 = "${var.vnet_name}-private-web-2"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_2_cidr]
}

# Private App Subnets (backend VMSS)
resource "azurerm_subnet" "private_app_1" {
  name                 = "${var.vnet_name}-private-app-1"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_3_cidr]
}

resource "azurerm_subnet" "private_app_2" {
  name                 = "${var.vnet_name}-private-app-2"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_4_cidr]
}

# Private DB Subnets (Azure Database flexible server)
resource "azurerm_subnet" "private_db_1" {
  name                 = "${var.vnet_name}-private-db-1"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_5_cidr]
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "private_db_2" {
  name                 = "${var.vnet_name}-private-db-2"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnet_6_cidr]
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# ─────────────────────────────────────────────────────
# NAT GATEWAY  (AWS NAT Gateway equivalent)
# ─────────────────────────────────────────────────────
resource "azurerm_public_ip" "nat_pip" {
  name                = "${var.vnet_name}-nat-pip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat" {
  name                = "${var.vnet_name}-nat"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat_pip.id
}

# Associate NAT GW with private subnets
resource "azurerm_subnet_nat_gateway_association" "private_web_1" {
  subnet_id      = azurerm_subnet.private_web_1.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private_web_2" {
  subnet_id      = azurerm_subnet.private_web_2.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private_app_1" {
  subnet_id      = azurerm_subnet.private_app_1.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private_app_2" {
  subnet_id      = azurerm_subnet.private_app_2.id
  nat_gateway_id = azurerm_nat_gateway.nat.id
}

# ─────────────────────────────────────────────────────
# NETWORK SECURITY GROUPS  (AWS Security Groups equivalent)
# ─────────────────────────────────────────────────────

# Bastion NSG
resource "azurerm_network_security_group" "bastion" {
  name                = "bastion-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Name = "bastion-nsg" }
}

# ALB Frontend NSG
resource "azurerm_network_security_group" "alb_frontend" {
  name                = "alb-frontend-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 112
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Name = "alb-frontend-nsg" }
}

# ALB Backend NSG
resource "azurerm_network_security_group" "alb_backend" {
  name                = "alb-backend-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Name = "alb-backend-nsg" }
}

# Frontend Server NSG
resource "azurerm_network_security_group" "frontend_server" {
  name                = "frontend-server-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Name = "frontend-server-nsg" }
}

# Backend Server NSG
resource "azurerm_network_security_group" "backend_server" {
  name                = "backend-server-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { Name = "backend-server-nsg" }
}

# Database NSG
resource "azurerm_network_security_group" "database" {
  name                = "database-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-MySQL"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*" # Restrict to backend subnet CIDR in production
    destination_address_prefix = "*"
  }

  tags = { Name = "database-nsg" }
}

# ─────────────────────────────────────────────────────
# NSG → Subnet associations
# ─────────────────────────────────────────────────────
resource "azurerm_subnet_network_security_group_association" "public_1" {
  subnet_id                 = azurerm_subnet.public_1.id
  network_security_group_id = azurerm_network_security_group.alb_frontend.id
}

resource "azurerm_subnet_network_security_group_association" "public_2" {
  subnet_id                 = azurerm_subnet.public_2.id
  network_security_group_id = azurerm_network_security_group.alb_frontend.id
}

resource "azurerm_subnet_network_security_group_association" "private_web_1" {
  subnet_id                 = azurerm_subnet.private_web_1.id
  network_security_group_id = azurerm_network_security_group.frontend_server.id
}

resource "azurerm_subnet_network_security_group_association" "private_web_2" {
  subnet_id                 = azurerm_subnet.private_web_2.id
  network_security_group_id = azurerm_network_security_group.frontend_server.id
}

resource "azurerm_subnet_network_security_group_association" "private_app_1" {
  subnet_id                 = azurerm_subnet.private_app_1.id
  network_security_group_id = azurerm_network_security_group.backend_server.id
}

resource "azurerm_subnet_network_security_group_association" "private_app_2" {
  subnet_id                 = azurerm_subnet.private_app_2.id
  network_security_group_id = azurerm_network_security_group.backend_server.id
}

resource "azurerm_subnet_network_security_group_association" "private_db_1" {
  subnet_id                 = azurerm_subnet.private_db_1.id
  network_security_group_id = azurerm_network_security_group.database.id
}

resource "azurerm_subnet_network_security_group_association" "private_db_2" {
  subnet_id                 = azurerm_subnet.private_db_2.id
  network_security_group_id = azurerm_network_security_group.database.id
}
