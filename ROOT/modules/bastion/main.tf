resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.project_name}-bastion-pip"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { Name = "bastion-pip" }
}

resource "azurerm_network_interface" "bastion" {
  name                = "${var.project_name}-bastion-nic"
  location            = var.azure_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "bastion-ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "bastion" {
  network_interface_id      = azurerm_network_interface.bastion.id
  network_security_group_id = var.nsg_id
}

# Azure Linux VM  (AWS EC2 equivalent)
resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "${var.project_name}-bastion"
  location            = var.azure_location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  network_interface_ids = [azurerm_network_interface.bastion.id]

  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Azure Marketplace Ubuntu Server image.
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = { Name = "bastion-host" }
}
