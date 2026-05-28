resource "azurerm_virtual_hub" "this" {
  name                             = local.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  virtual_wan_id                   = var.virtual_wan_id
  address_prefix                   = var.address_prefix
  sku                              = var.sku
  hub_routing_preference           = var.hub_routing_preference
  branch_to_branch_traffic_enabled = var.branch_to_branch_traffic_enabled
  dynamic "route" {
    for_each = var.routes
    content {
      address_prefixes    = route.value.address_prefixes
      next_hop_ip_address = route.value.next_hop_ip_address
    }
  }

  virtual_router_auto_scale_min_capacity = var.virtual_router_auto_scale_min_capacity
  tags                                   = local.tags
  lifecycle {
    ignore_changes = [
      tags["created_by"],
      tags["created_date"],
      tags["last_modified"]
    ]
  }
}
