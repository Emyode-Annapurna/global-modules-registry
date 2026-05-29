output "id" {
  description = "The resource ID of the Virtual WAN"
  value       = azurerm_virtual_wan.this.id
}

output "name" {
  description = "The name of the Virtual WAN"
  value       = azurerm_virtual_wan.this.name
}

output "location" {
  description = "The Azure region of the Virtual WAN"
  value       = azurerm_virtual_wan.this.location
}

output "resource_group_name" {
  description = "The Resource Group name of the Virtual WAN"
  value       = azurerm_virtual_wan.this.resource_group_name
}

output "type" {
  description = "The type of the Virtual WAN (Basic or Standard)"
  value       = azurerm_virtual_wan.this.type
}
