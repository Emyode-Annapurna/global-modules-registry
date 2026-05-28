variable "name" {
  description = "Base name of the Virtual Hub."
  type        = string
}

variable "name_suffix" {
  description = "Optional suffix appended to the name."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "location" {
  description = "Azure region where the Virtual Hub will be deployed."
  type        = string
}

variable "virtual_wan_id" {
  description = "ID of the parent Virtual WAN."
  type        = string
}

variable "address_prefix" {
  description = "CIDR address prefix for the Virtual Hub."
  type        = string
}

variable "sku" {
  description = "SKU of the Virtual Hub."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be 'Basic' or 'Standard'."
  }
}

variable "hub_routing_preference" {
  description = "Preferred routing method. Allowed values: ExpressRoute, VpnGateway, ASPath."
  type        = string
  default     = null
}

variable "branch_to_branch_traffic_enabled" {
  description = "Enable branch-to-branch traffic routing."
  type        = bool
  default     = true
}

variable "routes" {
  description = "Simple static routes to inject into the hub."
  type = list(object({
    address_prefixes    = list(string)
    next_hop_ip_address = string
  }))
  default = []
}

variable "virtual_router_auto_scale_min_capacity" {
  description = "Minimum scale units for the Virtual Router."
  type        = number
  default     = null
}

variable "tags" {
  description = "Additional custom tags."
  type        = map(string)
  default     = {}
}

variable "default_tags" {
  description = "Default tags applied to all resources."
  type        = map(string)
  default = {
    ManagedBy      = "Terraform"
    Environment    = "dev"
    LineOfBusiness = ""
  }
}
