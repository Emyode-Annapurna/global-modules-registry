variable "name" {
  description = "Name of the Virtual WAN resource"
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 80
    error_message = "Virtual WAN name must be between 1 and 80 characters"
  }
}

variable "resource_group_name" {
  description = "Name of the Resource Group in which to create the Virtual WAN"
  type        = string
}

variable "location" {
  description = "Azure region where the Virtual WAN will be deployed (e.g. 'canadacentral')"
  type        = string
}

variable "type" {
  description = "Type of the Virtual WAN. Allowed values: 'Basic' or 'Standard'"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.type)
    error_message = "Virtual WAN type must be either 'Basic' or 'Standard'"
  }
}

variable "disable_vpn_encryption" {
  description = "Whether VPN encryption is disabled. Defaults to false"
  type        = bool
  default     = false
}

variable "allow_branch_to_branch_traffic" {
  description = "Whether branch-to-branch traffic is allowed through the Virtual WAN. Defaults to true"
  type        = bool
  default     = true
}

variable "office365_local_breakout_category" {
  description = "Specifies the Office 365 local breakout category. Allowed values: 'Optimize', 'OptimizeAndAllow', 'All', 'None'"
  type        = string
  default     = "None"

  validation {
    condition     = contains(["Optimize", "OptimizeAndAllow", "All", "None"], var.office365_local_breakout_category)
    error_message = "office365_local_breakout_category must be one of: 'Optimize', 'OptimizeAndAllow', 'All', 'None'"
  }
}

variable "tags" {
  description = "A map of tags to assign to the Virtual WAN resource"
  type        = map(string)
  default     = {}
}
