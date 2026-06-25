# ─────────────────────────────────────────────────────
# Backend VM  (AWS EC2 backend equivalent)
# ─────────────────────────────────────────────────────

resource "azurerm_network_interface" "backend" {
  name                = "${var.project_name}-backend-nic"
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "backend-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "backend" {
  network_interface_id      = azurerm_network_interface.backend.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "backend" {
  name                = "${var.project_name}-backend-vm"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.backend.id]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt remove -y nodejs libnode-dev nodejs-doc
    sudo apt autoremove -y
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo apt-get install -y git mariadb-server
    sudo npm install -g pm2
  EOF
  )

  tags = { Name = "backend-vm" }
}
