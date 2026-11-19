# Azure Pipelines: Terraform (Validate, Plan, Apply)

Template pipeline in [azure-pipelines.yml](./azure-pipelines.yml). Test it on a sandbox project first.

## Flow
| Stage | Identity | Runs on | Purpose |
|-------|----------|---------|---------|
| Validate | none | PR and push | `fmt`, `init -backend=false`, `validate` |
| Plan | read-only service connection | PR and push | saved plan file, readable text plan |
| Apply | write service connection | push to `main` or `develop`, after Environment approval | applies the saved plan only |
| Destroy | dev write service connection | manual run, parameter `runDestroy`, `develop` branch | tear down dev |

## Design decisions
- **OIDC only**: service connections use workload identity federation; the pipeline never holds a client secret.
- **Two identities per environment**: a compromised plan job (for example from a pull request) cannot change infrastructure.
- **Approval on Environments**, not in the YAML: configure required approvers on `tf-dev`, `tf-prod`, `tf-dev-destroy`.
- **Apply the approved plan**: `terraform apply tfplan`; a stale plan is rejected by Terraform.
- **Pinned Terraform** with checksum verification (`templates/install-terraform.yml`).
- Pull request plans use the dev identity; the prod plan is produced after merge to `main`.

## Placeholders
`<STACK_PATH>`, `<SUBSCRIPTION_ID>`, service connection names `sc-contoso-<env>-plan|apply`, variable groups `tf-backend-<env>`.

## AWS from Azure DevOps
Use the same shape with an AWS-capable service connection or federated token and the roles from `terraform/modules/aws-iam-oidc-pipeline-roles`. The trust policy must match the exact `sub` your organization emits.

## Hardening checklist
- Restrict who can edit the pipeline and the Environments; require a second approver who is not the author.
- Protect `main` and `develop` with branch policies and build validation.
- Treat the plan artifact as sensitive.
- Add the optional gates from `../security-gates` (RECOMMENDED, not included by default).
