# Module: azure-storage-diag

Generic hardened storage account to receive diagnostic logs. Template: review before adopting.

## Controls
- `min_tls_version = TLS1_2`, HTTPS only, no public blob access.
- Firewall `default_action = Deny` with bypass for Azure Monitor services; optional IP and subnet allow lists.
- Key-based authentication disabled by default (`shared_access_key_enabled = false`). Test your log producers before enforcing it in an existing environment.
- Soft delete and a lifecycle policy that deletes log blobs after `retention_days`.
- Name = `name_prefix` + 6 random characters (`random_string`), because storage account names are global.

## Inputs
| Name | Required | Default |
|------|----------|---------|
| `resource_group_name` | yes | - |
| `location` | yes | - |
| `name_prefix` | no | `stdiag` |
| `replication_type` | no | `LRS` |
| `shared_access_key_enabled` | no | `false` |
| `allowed_ip_ranges` | no | `[]` |
| `allowed_subnet_ids` | no | `[]` |
| `retention_days` | no | `90` |
| `soft_delete_days` | no | `7` |
| `tags` | no | `{}` |

## Outputs
`storage_account_id`, `storage_account_name`.

## Notes
- Retention must follow your own legal and regulatory requirements; the default is only an example.
- With the firewall on, an administrator reading logs from outside Azure needs an entry in `allowed_ip_ranges`.
- Example: [examples/basic](./examples/basic/main.tf).
