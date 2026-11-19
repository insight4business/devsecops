# Module: aws-hardened-ec2

Generic EC2 instance with a secure baseline. Template: review before adopting.

## Controls
| Control | How |
|---------|-----|
| No SSH | no `key_name`; no inbound security group rule |
| Remote access | SSM Session Manager (`AmazonSSMManagedInstanceCore` on the instance role) |
| IMDSv2 only | `http_tokens = "required"`, hop limit 1 |
| Disk encryption | `root_block_device.encrypted = true` (optional customer KMS key) |
| Private by default | `associate_public_ip = false` |
| AMI | read from an SSM parameter; `ignore_changes = [ami]` prevents replacement on new releases |

## Inputs
| Name | Required | Default |
|------|----------|---------|
| `name` | yes | - |
| `subnet_id` | yes | - |
| `instance_type` | no | `t3.small` |
| `ami_ssm_parameter` | no | Amazon Linux 2023 public parameter |
| `root_volume_size_gb` | no | `20` |
| `kms_key_arn` | no | `null` |
| `egress_cidrs` | no | `["0.0.0.0/0"]` (HTTPS only) |
| `associate_public_ip` | no | `false` |
| `tags` | no | `{}` |

## Outputs
`instance_id`, `private_ip`, `security_group_id`, `iam_role_name`.

## Notes
- The instance needs a route to the SSM endpoints (NAT or VPC endpoints for `ssm`, `ssmmessages`, `ec2messages`).
- To pick up a newer AMI: `terraform apply -replace=module.<name>.aws_instance.this`.
- Example: [examples/basic](./examples/basic/main.tf).
