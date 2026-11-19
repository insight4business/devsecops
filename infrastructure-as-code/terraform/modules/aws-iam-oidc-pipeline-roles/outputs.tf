output "plan_role_arn" {
  description = "Role ARN for the plan job (read-only)."
  value       = aws_iam_role.plan.arn
}

output "apply_role_arn" {
  description = "Role ARN for the apply job (write, bounded)."
  value       = aws_iam_role.apply.arn
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider used in the trust policies."
  value       = local.oidc_provider_arn
}

output "boundary_policy_arn" {
  description = "ARN of the permissions boundary attached to the apply role."
  value       = aws_iam_policy.boundary.arn
}
