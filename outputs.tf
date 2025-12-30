output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "ssh_command" {
  value = "ssh azureuser@${azurerm_public_ip.vm.ip_address}"
}
