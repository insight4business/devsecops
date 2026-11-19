variable "name_prefix" {
  description = "Prefix for role and policy names. Example: contoso-dev."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9+=,.@_-]{3,40}$", var.name_prefix))
    error_message = "name_prefix must be 3-40 characters valid in IAM names."
  }
}

# --- OIDC identity provider ----------------------------------------------------
variable "oidc_provider_host" {
  description = "Host of the OIDC issuer (no scheme). Default is GitHub Actions. For other CI systems use the issuer host of your platform."
  type        = string
  default     = "token.actions.githubusercontent.com"
}

variable "oidc_audience" {
  description = "Expected value of the token `aud` claim. It must match what the pipeline requests."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "create_oidc_provider" {
  description = "Create the IAM OIDC provider. Set false when the account already has one for this issuer (only one is allowed per issuer)."
  type        = bool
  default     = true
}

variable "existing_oidc_provider_arn" {
  description = "ARN of an existing OIDC provider. Required when create_oidc_provider is false."
  type        = string
  default     = null

  validation {
    condition     = var.existing_oidc_provider_arn == null || can(regex("^arn:aws[a-z-]*:iam::", coalesce(var.existing_oidc_provider_arn, "x")))
    error_message = "existing_oidc_provider_arn must be an IAM ARN."
  }
}

variable "oidc_thumbprints" {
  description = "Optional CA thumbprints for the provider. Leave null unless your AWS provider version requires them."
  type        = list(string)
  default     = null
}

# --- Trust (who may assume the roles) ---------------------------------------------
# Exact `sub` values only. Wildcards are rejected on purpose: a wildcard in the
# subject lets any matching repository, branch or pull request assume the role.
variable "plan_subjects" {
  description = "Exact `sub` claims allowed to assume the plan (read-only) role. GitHub example: repo:contoso/infra:pull_request"
  type        = list(string)

  validation {
    condition     = length(var.plan_subjects) > 0 && alltrue([for s in var.plan_subjects : length(s) > 0 && !strcontains(s, "*")])
    error_message = "plan_subjects must be a non-empty list of exact values without wildcards."
  }
}

variable "apply_subjects" {
  description = "Exact `sub` claims allowed to assume the apply (write) role. Bind it to a protected environment or branch. GitHub example: repo:contoso/infra:environment:production"
  type        = list(string)

  validation {
    condition     = length(var.apply_subjects) > 0 && alltrue([for s in var.apply_subjects : length(s) > 0 && !strcontains(s, "*")])
    error_message = "apply_subjects must be a non-empty list of exact values without wildcards."
  }
}

# --- Terraform state access ---------------------------------------------------------
variable "state_bucket_arn" {
  description = "ARN of the S3 bucket holding Terraform state."
  type        = string
}

variable "state_kms_key_arn" {
  description = "KMS key used by the state bucket, if any."
  type        = string
  default     = null
}

variable "state_dynamodb_table_arn" {
  description = "DynamoDB lock table ARN. Null when using S3 native locking (lock file next to the state object)."
  type        = string
  default     = null
}

# --- Permissions ------------------------------------------------------------------------
variable "plan_policy_arns" {
  description = "Managed policies attached to the plan role. Read-only by default."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
}

# No default on purpose: the caller must define least privilege for what it deploys.
variable "apply_policy_arns" {
  description = "Managed policies attached to the apply role. Scope them to the services this pipeline manages; AdministratorAccess is rejected."
  type        = list(string)

  validation {
    condition     = length(var.apply_policy_arns) > 0 && !anytrue([for a in var.apply_policy_arns : endswith(a, "/AdministratorAccess")])
    error_message = "apply_policy_arns must be non-empty and must not include AdministratorAccess."
  }
}

variable "passable_role_arns" {
  description = "Roles the apply role may pass to AWS services (iam:PassRole). Empty means no PassRole at all."
  type        = list(string)
  default     = []
}

variable "passrole_services" {
  description = "Services that may receive the passed roles (condition iam:PassedToService)."
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "boundary_extra_denied_actions" {
  description = "Additional actions denied by the permissions boundary."
  type        = list(string)
  default     = []
}

variable "max_session_duration" {
  description = "Maximum session length in seconds for both roles."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200."
  }
}

variable "tags" {
  description = "Tags applied to every resource. Use the standard keys: Project, Environment, ManagedBy, Owner."
  type        = map(string)
  default     = {}
}
