variable "env" {
  description = "Environment name (dev, pilot, prod, etc.)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group containing the virtual network"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the virtual network where subnets will be created"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "Map of subnets to create, with optional NSG, delegation, and service endpoints"
  type = map(object({
    address_prefixes = list(string)
    create_nsg       = optional(bool, false)
    nsg_name         = optional(string)
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = list(string)
      destination_address_prefix = string
    })), [])

    enable_delegation  = optional(bool, false)
    delegation_service = optional(string)
    service_endpoints  = optional(list(string), [])
  }))
}
