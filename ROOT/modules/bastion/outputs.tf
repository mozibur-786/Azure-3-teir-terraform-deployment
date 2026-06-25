output "bastion_vm_id" {
  value = azurerm_linux_virtual_machine.bastion.id
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

output "bastion_private_ip" {
  value = azurerm_network_interface.bastion.private_ip_address
}
