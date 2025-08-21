output "github-runner-public_ip" {
  value = azurerm_public_ip.default.ip_address
}