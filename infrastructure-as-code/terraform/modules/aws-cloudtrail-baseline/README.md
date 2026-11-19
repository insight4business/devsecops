# Module: aws-cloudtrail-baseline

Generic single-account CloudTrail baseline. Template: review before adopting.

## What it creates
- **Multi-region trail** with management events (read and write), global service events and **log file validation**.
- **KMS key** (optional, rotation on) whose policy lets CloudTrail encrypt only for this account's trails.
- **Private log bucket**: public access block, owner enforced, SSE-KMS (or SSE-S3), versioning, retention lifecycle, TLS-only policy, CloudTrail write access restricted by `aws:SourceArn`.

## Inputs
| Name | Required | Default |
|------|----------|---------|
| `trail_name` | yes | - |
| `log_bucket_name` | yes | - |
| `create_kms_key` | no | `true` |
| `kms_key_arn` | no | `null` (only when `create_kms_key = false`) |
| `log_retention_days` | no | `365` (minimum 90) |
| `include_global_service_events` | no | `true` |
| `force_destroy` | no | `false` |
| `tags` | no | `{}` |

## Outputs
`trail_arn`, `log_bucket_id`, `kms_key_arn`.

## Notes
- Only one multi-region management trail per account is free of extra event charges; additional trails are billed.
- Not included: organization trails, data events, CloudWatch Logs delivery, alarms and log replication to another account. Add them according to your needs.
- Retention is an example; align it with your own legal requirements.
- Example: [examples/basic](./examples/basic/main.tf).
