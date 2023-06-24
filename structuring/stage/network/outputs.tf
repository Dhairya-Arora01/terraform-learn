output "public-ip" {
  value = azurerm_public_ip.publicIp.ip_address
}