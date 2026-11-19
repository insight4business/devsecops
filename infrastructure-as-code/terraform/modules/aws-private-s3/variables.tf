variable "bucket_name" {
  description = "Globally unique bucket name. Example: contoso-app-data-dev."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters: lowercase letters, digits, dots and hyphens."
  }
}

variable "force_destroy" {
  description = "Allow Terraform to delete a non-empty bucket. Keep false outside disposable environments."
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Keep previous versions of objects (protection against overwrite and deletion)."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Customer-managed KMS key for SSE-KMS. When null, SSE-S3 (AES256) is used."
  type        = string
  default     = null
}

variable "minimum_tls_version" {
  description = "Minimum TLS version accepted by the bucket policy. Use \"1.2\" or \"1.3\"."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be \"1.2\" or \"1.3\"."
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Days after which noncurrent object versions are deleted. Only used when versioning is enabled."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_expiration_days >= 1
    error_message = "noncurrent_version_expiration_days must be at least 1."
  }
}

variable "transition_to_ia_days" {
  description = "Days after which current objects move to STANDARD_IA. Null disables the transition (minimum allowed by S3 is 30)."
  type        = number
  default     = null

  validation {
    condition     = var.transition_to_ia_days == null || coalesce(var.transition_to_ia_days, 30) >= 30
    error_message = "transition_to_ia_days must be null or at least 30."
  }
}

variable "expiration_days" {
  description = "Days after which current objects are deleted. Null keeps them indefinitely."
  type        = number
  default     = null
}

variable "abort_incomplete_multipart_days" {
  description = "Days after which incomplete multipart uploads are aborted."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to every resource. Use the standard keys: Project, Environment, ManagedBy, Owner."
  type        = map(string)
  default     = {}
}
