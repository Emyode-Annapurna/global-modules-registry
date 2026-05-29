resource "azurerm_virtual_hub_connection" "this" {
  name                      = var.name
  virtual_hub_id            = var.virtual_hub_id
  remote_virtual_network_id = var.remote_virtual_network_id
  internet_security_enabled = var.internet_security_enabled

  dynamic "routing" {
    for_each = var.routing == null ? [] : [var.routing]
    content {
      associated_route_table_id = try(routing.value.associated_route_table_id, null)
      inbound_route_map_id      = try(routing.value.inbound_route_map_id, null)
      outbound_route_map_id     = try(routing.value.outbound_route_map_id, null)

      dynamic "static_vnet_route" {
        for_each = try(routing.value.static_vnet_route, [])
        content {
          name                = static_vnet_route.value.name
          address_prefixes    = static_vnet_route.value.address_prefixes
          next_hop_ip_address = static_vnet_route.value.next_hop_ip_address
        }
      }

      dynamic "propagated_route_table" {
        for_each = try(routing.value.propagated_route_table, null) == null ? [] : [routing.value.propagated_route_table]
        content {
          labels          = try(propagated_route_table.value.labels, [])
          route_table_ids = try(propagated_route_table.value.route_table_ids, [])
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = try(timeouts.value.create, null)
      read   = try(timeouts.value.read, null)
      update = try(timeouts.value.update, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
