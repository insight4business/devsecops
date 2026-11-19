# Module: azure-vnet-baseline

Generic Azure network baseline. Template: review before adopting.

## What it creates
- Resource group, VNet and one workload subnet.
- NSG associated to the subnet with **no custom allow rule** and an explicit `deny-all-inbound` (priority 4096). Azure built-in rules cannot be removed.
- An admin allow rule **only** when `admin_source_cidrs` is not empty.
- Optional NAT gateway with a static Standard public IP (`enable_nat_gateway`, uses `count`).

## Inputs
| Name | Required | Default | Notes |
|------|----------|---------|-------|
| `name` | yes | - | prefix for all names |
| `location` | yes | - | |
| `admin_source_cidrs` | **yes** | none | `[]` for no admin access; `0.0.0.0/0` is rejected |
| `address_space` | no | `["10.0.0.0/16"]` | |
| `subnet_prefix` | no | `"10.0.0.0/24"` | |
| `admin_ports` | no | `["22"]` | |
| `enable_nat_gateway` | no | `false` | |
| `tags` | no | `{}` | |

## Outputs
`resource_group_name`, `vnet_id`, `subnet_id`, `nsg_id`, `nat_public_ip`.

## Notes
- Prefer a bastion or just-in-time access over opening admin ports.
- The provider needs `subscription_id` (azurerm 4.x); set it with `ARM_SUBSCRIPTION_ID` in pipelines.
- Example: [examples/basic](./examples/basic/main.tf).
