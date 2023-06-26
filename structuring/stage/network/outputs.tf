output "public-ip" {
  value = azurerm_public_ip.publicIp.ip_address
}

output "nicId" {
  value = azurerm_network_interface.nic.id
}