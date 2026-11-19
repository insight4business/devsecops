variable "trail_name" {
  description = "CloudTrail trail name. Example: contoso-management-events."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{2,127}$", var.trail_name))
    error_message = "trail_name must be 3-128 characters: letters, digits, dots, underscores and hyphens."
  }
}

variable "log_bucket_name" {
  description = "Globally unique name for the log bucket created by this module."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.log_bucket_name))
    error_message = "log_bucket_name must be 3-63 characters: lowercase letters, digits, dots and hyphens."
  }
}

variable "create_kms_key" {
  description = "Create a customer-managed KMS key for log encryption. If false, set kms_key_arn (or leave null for SSE-S3 on the bucket and an unencrypted-by-key trail)."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Existing KMS key ARN. Used only when create_kms_key is false. Its key policy must allow CloudTrail."
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Days before log objects expire. Choose according to your legal and regulatory requirements."
  type        = number
  default     = 365

  validation {
    condition     = var.log_retention_days >= 90
    error_message = "log_retention_days must be at least 90."
  }
}

variable "include_global_service_events" {
  description = "Record events of global services such as IAM."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow deleting the log bucket with objects in it. Keep false: logs are evidence."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to every resource. Use the standard keys: Project, Environment, ManagedBy, Owner."
  type        = map(string)
  default     = {}
}
