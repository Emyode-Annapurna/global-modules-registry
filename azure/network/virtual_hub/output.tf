output "id" {
  description = "Virtual Hub resource ID."
  value       = azurerm_virtual_hub.this.id
}

output "name" {
  description = "Name of the Virtual Hub."
  value       = azurerm_virtual_hub.this.name
}

output "virtual_router_asn" {
  description = "BGP ASN of the Virtual Hub router."
  value       = azurerm_virtual_hub.this.virtual_router_asn
}

output "virtual_router_ips" {
  description = "Virtual Router IP addresses."
  value       = azurerm_virtual_hub.this.virtual_router_ips
}

output "this" {
  description = "Full resource object."
  value       = azurerm_virtual_hub.this
}

output "default_route_table_id" {
  description = "The ID of the default Route Table in the Virtual Hub"
  value       = azurerm_virtual_hub.this.default_route_table_id
}
