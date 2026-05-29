variable "name" {
  description = "Name of the Virtual Hub connection"
  type        = string
  nullable    = false

  validation {
    condition     = length(trim(var.name, " ")) > 0 && length(var.name) <= 80
    error_message = "The name must be non-empty and no longer than 80 characters"
  }
}

variable "virtual_hub_id" {
  description = "Resource ID of the target Virtual Hub"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/.+/providers/Microsoft\\.Network/virtualHubs/.+$", var.virtual_hub_id))
    error_message = "virtual_hub_id must be a valid Azure Virtual Hub resource ID"
  }
}

variable "remote_virtual_network_id" {
  description = "Resource ID of the remote Virtual Network to connect"
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^/subscriptions/.+/providers/Microsoft\\.Network/virtualNetworks/.+$", var.remote_virtual_network_id))
    error_message = "remote_virtual_network_id must be a valid Azure Virtual Network resource ID."
  }
}

variable "internet_security_enabled" {
  description = "Whether internet security is enabled on the connection"
  type        = bool
  default     = false
}

variable "routing" {
  description = "Optional routing configuration for the Virtual Hub connection"
  type = object({
    associated_route_table_id                 = optional(string)
    inbound_route_map_id                      = optional(string)
    outbound_route_map_id                     = optional(string)
    static_vnet_local_route_override_criteria = optional(string)
    static_vnet_route = optional(list(object({
      name                = string
      address_prefixes    = list(string)
      next_hop_ip_address = string
    })), [])
    propagated_route_table = optional(object({
      labels          = optional(list(string), [])
      route_table_ids = optional(list(string), [])
    }))
  })
  default = null

  validation {
    condition = var.routing == null || alltrue([
      for route in try(var.routing.static_vnet_route, []) :
      length(route.address_prefixes) > 0
    ])
    error_message = "Each static_vnet_route entry must include at least one address prefix"
  }

  validation {
    condition     = var.routing == null || try(var.routing.static_vnet_local_route_override_criteria, null) == null || contains(["Contains", "Equal"], var.routing.static_vnet_local_route_override_criteria)
    error_message = "routing.static_vnet_local_route_override_criteria must be either \"Contains\" or \"Equal\"."
  }
}

variable "timeouts" {
  description = "Optional custom timeouts"
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
