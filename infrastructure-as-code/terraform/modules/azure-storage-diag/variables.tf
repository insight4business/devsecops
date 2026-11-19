variable "name_prefix" {
  description = "Prefix of the storage account name. Lowercase letters and digits only; the module appends a random suffix."
  type        = string
  default     = "stdiag"

  validation {
    condition     = can(regex("^[a-z0-9]{3,16}$", var.name_prefix))
    error_message = "name_prefix must be 3-16 lowercase letters or digits (the account name is limited to 24 characters)."
  }
}

variable "resource_group_name" {
  description = "Existing resource group where the storage account is created."
  type        = string
}

variable "location" {
  description = "Azure region. Example: eastus2."
  type        = string
}

variable "replication_type" {
  description = "Replication: LRS, ZRS, GRS or RAGRS."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS"], var.replication_type)
    error_message = "replication_type must be LRS, ZRS, GRS or RAGRS."
  }
}

variable "shared_access_key_enabled" {
  description = "Allow account-key authentication. false forces Microsoft Entra ID authentication. Test your log producers before disabling."
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "Public IPs or CIDRs allowed through the storage firewall (for administrators or collectors). Empty list means only trusted Azure services and allowed subnets."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs (with the Microsoft.Storage service endpoint) allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "retention_days" {
  description = "Days after which log blobs are deleted by the lifecycle policy."
  type        = number
  default     = 90

  validation {
    condition     = var.retention_days >= 1
    error_message = "retention_days must be at least 1."
  }
}

variable "soft_delete_days" {
  description = "Soft-delete retention for blobs and containers."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to every resource. Use the standard keys: Project, Environment, ManagedBy, Owner."
  type        = map(string)
  default     = {}
}
