output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = { for name, subnet in azurerm_subnet.this : name => subnet.id }
}

output "nsg_ids" {
  description = "Map of subnet names (with NSG) to NSG IDs"
  value       = { for name, nsg in azurerm_network_security_group.this : name => nsg.id }
}
