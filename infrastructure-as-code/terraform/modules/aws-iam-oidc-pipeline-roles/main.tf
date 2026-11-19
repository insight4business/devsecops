# IAM roles for a Terraform pipeline using OIDC (no static access keys).
#   plan role  : read-only, assumed by pull request runs.
#   apply role : write access, assumed only from a protected environment/branch,
#                capped by a permissions boundary and a restricted iam:PassRole.

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  partition  = data.aws_partition.current.partition
  account_id = data.aws_caller_identity.current.account_id

  plan_role_name     = "${var.name_prefix}-tf-plan"
  apply_role_name    = "${var.name_prefix}-tf-apply"
  boundary_name      = "${var.name_prefix}-tf-boundary"
  oidc_url_scheme    = "https"
  oidc_provider_arn  = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : var.existing_oidc_provider_arn
  boundary_arn       = "arn:${local.partition}:iam::${local.account_id}:policy/${local.boundary_name}"
  pipeline_role_arns = [for n in [local.plan_role_name, local.apply_role_name] : "arn:${local.partition}:iam::${local.account_id}:role/${n}"]
}

# --- OIDC provider -----------------------------------------------------------------
resource "aws_iam_openid_connect_provider" "this" {
  count = var.create_oidc_provider ? 1 : 0

  url             = "${local.oidc_url_scheme}://${var.oidc_provider_host}"
  client_id_list  = [var.oidc_audience]
  thumbprint_list = var.oidc_thumbprints
  tags            = var.tags
}

# --- Trust policies: audience AND exact subject must match ----------------------------
data "aws_iam_policy_document" "trust_plan" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:aud"
      values   = [var.oidc_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:sub"
      values   = var.plan_subjects
    }
  }
}

data "aws_iam_policy_document" "trust_apply" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:aud"
      values   = [var.oidc_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:sub"
      values   = var.apply_subjects
    }
  }
}

# --- Terraform state access (shared building blocks) ------------------------------------
data "aws_iam_policy_document" "state_read" {
  statement {
    sid       = "StateList"
    actions   = ["s3:ListBucket", "s3:GetBucketVersioning"]
    resources = [var.state_bucket_arn]
  }

  statement {
    sid       = "StateRead"
    actions   = ["s3:GetObject"]
    resources = ["${var.state_bucket_arn}/*"]
  }

  # S3 native locking writes a small ".tflock" object. The plan role may only touch those.
  statement {
    sid       = "StateLockFile"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.state_bucket_arn}/*.tflock"]
  }

  dynamic "statement" {
    for_each = var.state_dynamodb_table_arn == null ? [] : [1]
    content {
      sid       = "StateLockTable"
      actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
      resources = [var.state_dynamodb_table_arn]
    }
  }

  dynamic "statement" {
    for_each = var.state_kms_key_arn == null ? [] : [1]
    content {
      sid       = "StateKms"
      actions   = ["kms:Decrypt", "kms:GenerateDataKey"]
      resources = [var.state_kms_key_arn]
    }
  }
}

data "aws_iam_policy_document" "state_write" {
  source_policy_documents = [data.aws_iam_policy_document.state_read.json]

  statement {
    sid       = "StateWrite"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${var.state_bucket_arn}/*"]
  }
}

# --- Permissions boundary for the apply role -------------------------------------------------
# The effective permissions of the apply role are the INTERSECTION of its attached
# policies and this boundary. The boundary allows everything except privilege
# escalation paths and tampering with audit/identity controls.
data "aws_iam_policy_document" "boundary" {
  statement {
    sid       = "AllowWithinAttachedPolicies"
    actions   = ["*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyIdentityAndAccountChanges"
    effect = "Deny"
    actions = concat([
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:UpdateLoginProfile",
      "organizations:*",
      "account:*",
    ], var.boundary_extra_denied_actions)
    resources = ["*"]
  }

  statement {
    sid       = "DenyAuditTampering"
    effect    = "Deny"
    actions   = ["cloudtrail:StopLogging", "cloudtrail:DeleteTrail"]
    resources = ["*"]
  }

  # Any role the pipeline creates must carry this same boundary.
  statement {
    sid       = "RequireBoundaryOnNewRoles"
    effect    = "Deny"
    actions   = ["iam:CreateRole", "iam:PutRolePermissionsBoundary"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "iam:PermissionsBoundary"
      values   = [local.boundary_arn]
    }
  }

  statement {
    sid       = "DenyBoundaryRemovalOrEdit"
    effect    = "Deny"
    actions   = ["iam:DeleteRolePermissionsBoundary", "iam:CreatePolicyVersion", "iam:DeletePolicyVersion", "iam:SetDefaultPolicyVersion", "iam:DeletePolicy"]
    resources = [local.boundary_arn]
  }

  # The pipeline cannot widen its own roles.
  statement {
    sid    = "DenySelfModification"
    effect = "Deny"
    actions = [
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:UpdateAssumeRolePolicy",
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteRole",
    ]
    resources = local.pipeline_role_arns
  }
}

resource "aws_iam_policy" "boundary" {
  name        = local.boundary_name
  description = "Permissions boundary for the Terraform apply role."
  policy      = data.aws_iam_policy_document.boundary.json
  tags        = var.tags
}

# --- Plan role (read-only) ------------------------------------------------------------------------
resource "aws_iam_role" "plan" {
  name                 = local.plan_role_name
  description          = "Terraform plan (read-only), assumed through OIDC."
  assume_role_policy   = data.aws_iam_policy_document.trust_plan.json
  max_session_duration = var.max_session_duration
  tags                 = var.tags

  lifecycle {
    precondition {
      condition     = var.create_oidc_provider || var.existing_oidc_provider_arn != null
      error_message = "Set existing_oidc_provider_arn when create_oidc_provider is false."
    }
  }
}

resource "aws_iam_role_policy_attachment" "plan" {
  for_each = toset(var.plan_policy_arns)

  role       = aws_iam_role.plan.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "plan_state" {
  name   = "terraform-state-read"
  role   = aws_iam_role.plan.id
  policy = data.aws_iam_policy_document.state_read.json
}

# --- Apply role (write, bounded) --------------------------------------------------------------------
resource "aws_iam_role" "apply" {
  name                 = local.apply_role_name
  description          = "Terraform apply (write), assumed through OIDC from a protected environment."
  assume_role_policy   = data.aws_iam_policy_document.trust_apply.json
  permissions_boundary = aws_iam_policy.boundary.arn
  max_session_duration = var.max_session_duration
  tags                 = var.tags
}

resource "aws_iam_role_policy_attachment" "apply" {
  for_each = toset(var.apply_policy_arns)

  role       = aws_iam_role.apply.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "apply_state" {
  name   = "terraform-state-write"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.state_write.json
}

# PassRole only for the listed roles and only to the listed services.
data "aws_iam_policy_document" "passrole" {
  count = length(var.passable_role_arns) > 0 ? 1 : 0

  statement {
    sid       = "PassOnlyListedRoles"
    actions   = ["iam:PassRole"]
    resources = var.passable_role_arns

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = var.passrole_services
    }
  }
}

resource "aws_iam_role_policy" "apply_passrole" {
  count = length(var.passable_role_arns) > 0 ? 1 : 0

  name   = "restricted-passrole"
  role   = aws_iam_role.apply.id
  policy = data.aws_iam_policy_document.passrole[0].json
}
