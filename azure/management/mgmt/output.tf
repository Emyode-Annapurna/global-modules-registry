output "id" {
  description = "The ID of the management group"
  value       = azurerm_management_group.this.id
}

output "name" {
  description = "The name (short ID) of the management group"
  value       = azurerm_management_group.this.name
}

output "display_name" {
  description = "The display name of the management group"
  value       = azurerm_management_group.this.display_name
}

output "subscription_association_ids" {
  description = "IDs of management group subscription associations (if created)"
  value       = [for a in azurerm_management_group_subscription_association.this : a.id]
}
