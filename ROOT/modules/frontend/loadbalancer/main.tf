# ─────────────────────────────────────────────────────
# Frontend Application Gateway / Load Balancer
# AWS ALB → Azure Application Gateway (Layer 7)
# ─────────────────────────────────────────────────────

resource "azurerm_public_ip" "frontend_pip" {
  name                = "${var.alb_name}-pip"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { Name = "${var.alb_name}-pip" }
}

locals {
  backend_address_pool_name = "${var.alb_name}-bepool"
  frontend_port_name        = "${var.alb_name}-feport"
  frontend_ip_config_name   = "${var.alb_name}-feip"
  http_setting_name         = "${var.alb_name}-http-settings"
  listener_name             = "${var.alb_name}-listener"
  routing_rule_name         = "${var.alb_name}-routing-rule"
  probe_name                = "${var.alb_name}-health-probe"
}

resource "azurerm_application_gateway" "frontend" {
  name                = var.alb_name
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.gateway_subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.frontend_pip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60

    probe_name = local.probe_name
  }

  probe {
    name                = local.probe_name
    protocol            = "Http"
    path                = "/"
    host                = "127.0.0.1"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_config_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 100
  }

  tags = { Name = var.alb_name }
}
