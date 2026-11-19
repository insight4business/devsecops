# Module: aws-iam-oidc-pipeline-roles

IAM roles for Terraform pipelines that authenticate by **OIDC federation** (no static access keys). Template: review before adopting.

## What it creates
- IAM OIDC provider (optional, one per issuer per account).
- **Plan role**: read-only managed policy plus state read and lock-file access.
- **Apply role**: caller-defined policies, **permissions boundary**, state write, and a **restricted `iam:PassRole`** (listed roles, listed services only).
- Trust policies require both `aud` and an **exact** `sub`. Wildcards are rejected by validation.

## Permissions boundary (apply role)
Allows everything that the attached policies allow, except: creating IAM users, access keys and login profiles; `organizations:*` and `account:*`; stopping or deleting CloudTrail; creating roles without the same boundary; removing or editing the boundary; and changing the pipeline roles themselves.
Consequence: the apply policies must let the pipeline create roles **with** the boundary (`iam:PermissionsBoundary` condition), and the pipeline cannot delete trails: do that through a separate, reviewed process.

## Inputs (main ones)
| Name | Required | Notes |
|------|----------|-------|
| `name_prefix` | yes | prefix for roles/policy |
| `plan_subjects` | yes | exact `sub` values, for pull requests |
| `apply_subjects` | yes | exact `sub` values, bound to a protected environment |
| `state_bucket_arn` | yes | Terraform state bucket |
| `apply_policy_arns` | **yes, no default** | least privilege; AdministratorAccess rejected |
| `oidc_provider_host` | no | default is the GitHub Actions issuer host |
| `oidc_audience` | no | default `sts.amazonaws.com` |
| `create_oidc_provider` / `existing_oidc_provider_arn` | no | reuse an existing provider |
| `passable_role_arns`, `passrole_services` | no | empty list grants no PassRole |
| `state_kms_key_arn`, `state_dynamodb_table_arn` | no | when the backend uses them |

## Outputs
`plan_role_arn`, `apply_role_arn`, `oidc_provider_arn`, `boundary_policy_arn`.

## Notes
- Subject formats differ per CI platform. Confirm the exact `sub` your platform emits before applying.
- The plan role can create and delete only `*.tflock` objects in the state bucket. If you prefer a strictly read-only plan, run plan with `-lock=false` and remove that statement.
- Leave `oidc_thumbprints` null unless your AWS provider version requires it.
- Example: [examples/basic](./examples/basic/main.tf).
