# Module: aws-private-s3

Generic S3 bucket baseline. Template: review before adopting.

## What it creates
- Bucket with **public access block** (all four settings).
- **Owner enforced** object ownership (ACLs disabled).
- **Server-side encryption**: SSE-KMS if `kms_key_arn` is set, SSE-S3 otherwise.
- **Versioning** (default on) and a **lifecycle** rule (old versions, abandoned uploads, optional tiering/expiry).
- **Bucket policy** denying non-TLS requests and TLS versions below `minimum_tls_version`.

## Inputs
| Name | Required | Default | Notes |
|------|----------|---------|-------|
| `bucket_name` | yes | - | validated against S3 naming rules |
| `force_destroy` | no | `false` | keep false outside disposable environments |
| `versioning_enabled` | no | `true` | |
| `kms_key_arn` | no | `null` | null means SSE-S3 |
| `minimum_tls_version` | no | `"1.2"` | `"1.2"` or `"1.3"` |
| `noncurrent_version_expiration_days` | no | `90` | |
| `transition_to_ia_days` | no | `null` | min 30 when set |
| `expiration_days` | no | `null` | null keeps current objects |
| `abort_incomplete_multipart_days` | no | `7` | |
| `tags` | no | `{}` | Project, Environment, ManagedBy, Owner |

## Outputs
`bucket_id`, `bucket_arn`, `bucket_regional_domain_name`.

## Notes
- When using a KMS key, the key policy must allow the principals that read and write the bucket.
- Add access logging, replication or Object Lock as needed; they are intentionally out of this baseline.
- Example: [examples/basic](./examples/basic/main.tf).
