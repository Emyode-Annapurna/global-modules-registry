variable "localgat_conf" {
  description = "Configuration for one Local Network Gateway"
  type = object({
    name                = string
    location            = string
    resource_group_name = string
    gateway_address     = string
    address_space       = list(string)
    bgp_settings = optional(object({
      asn                 = number
      bgp_peering_address = string
      peer_weight         = optional(number)
    }))
    tags = optional(map(string), {})
  })
  nullable = false
}
