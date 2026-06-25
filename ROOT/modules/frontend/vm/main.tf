# ─────────────────────────────────────────────────────
# Frontend VM  (AWS EC2 frontend equivalent)
# Used to build a custom image → then referenced by VMSS
# ─────────────────────────────────────────────────────

resource "azurerm_network_interface" "frontend" {
  name                = "${var.project_name}-frontend-nic"
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "frontend-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "frontend" {
  network_interface_id      = azurerm_network_interface.frontend.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_linux_virtual_machine" "frontend" {
  name                = "${var.project_name}-frontend-vm"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.frontend.id]

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

  # Equivalent to AWS user_data
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt remove -y nodejs libnode-dev nodejs-doc
    sudo apt autoremove -y
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
    sudo apt-get install -y nginx git
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF
  )

  tags = { Name = "frontend-vm" }
}
