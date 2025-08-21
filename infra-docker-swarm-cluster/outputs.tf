output "master_public_ip" {
  value = azurerm_public_ip.master[*].ip_address
}

output "worker_public_ip" {
  value = azurerm_public_ip.worker[*].ip_address
}