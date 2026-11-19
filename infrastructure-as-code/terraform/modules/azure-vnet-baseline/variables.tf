variable "name" {
  description = "Base name used as prefix for all resources. Example: contoso-dev."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.name))
    error_message = "name must be 3-40 characters: lowercase letters, digits and hyphens."
  }
}

variable "location" {
  description = "Azure region. Example: eastus2."
  type        = string
}

variable "address_space" {
  description = "VNet address space (CIDR list)."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "CIDR of the workload subnet. Must be inside address_space."
  type        = string
  default     = "10.0.0.0/24"

  validation {
    condition     = can(cidrnetmask(var.subnet_prefix))
    error_message = "subnet_prefix must be a valid CIDR."
  }
}

# No default on purpose: the caller must decide who can administer the subnet.
variable "admin_source_cidrs" {
  description = "Source CIDRs allowed to reach the admin ports (for example a VPN or bastion range). Use [] for no admin access. Never 0.0.0.0/0."
  type        = list(string)

  validation {
    condition     = alltrue([for c in var.admin_source_cidrs : can(cidrnetmask(c)) && c != "0.0.0.0/0"])
    error_message = "Each admin_source_cidrs entry must be a valid CIDR and must not be 0.0.0.0/0."
  }
}

variable "admin_ports" {
  description = "Destination ports opened to admin_source_cidrs (only when that list is not empty)."
  type        = list(string)
  default     = ["22"]
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway and public IP so the subnet has controlled outbound access."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource. Use the standard keys: Project, Environment, ManagedBy, Owner."
  type        = map(string)
  default     = {}
}
