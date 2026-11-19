# GitHub Actions: Terraform (validate, plan, apply)

Template workflow in [terraform.yml](./terraform.yml) (copy to `.github/workflows/`). Test on a sandbox repository first.

## Flow
| Job | Identity | Runs on | Purpose |
|-----|----------|---------|---------|
| validate | none | PR and push | `fmt`, `init -backend=false`, `validate`; decides dev or prod |
| plan | read-only role (OIDC) | PR and push | saved plan, text plan in the job summary |
| apply | write role (OIDC) | push to `main` or `develop`, after Environment approval | applies the saved plan only |
| destroy | dev write role (OIDC) | manual dispatch, input on, `develop` branch | tear down dev |

## Design decisions
- **OIDC only**: no access keys or secrets; `id-token: write` is granted per job, default permissions are empty.
- **Two roles per environment**: plan cannot write; apply is reachable only from a protected Environment.
- **Environment protection**: required reviewers and deployment branch rules on `dev`, `production`, `dev-destroy`. The plan job has no Environment so it never blocks.
- **Exact trust**: the AWS trust policy should match `repo:<ORG>/<REPO>:environment:<ENV>` for apply and `repo:<ORG>/<REPO>:pull_request` for plan (see the IAM module).
- **Apply the approved plan** with `terraform apply tfplan`.
- **Serialized runs**: `concurrency` group per ref, no cancellation of applies.
- Pull request plans use the dev role; the prod plan runs after merge to `main`.

## Variables
Repository variables: `AWS_PLAN_ROLE_ARN_DEV|PROD`, `AWS_APPLY_ROLE_ARN_DEV|PROD`. Placeholders in the file: `<STACK_PATH>`, `<AWS_REGION>`, `<STATE_BUCKET>`.

## Hardening checklist
- Pin actions to full commit SHAs; allow only trusted actions in the organization settings.
- Restrict who can approve; the author must not approve their own deployment.
- Treat the plan artifact as sensitive; keep retention short.
- With `pull_request` from forks, do not expose cloud roles; keep forks out of the plan job.
- Add the optional gates from `../security-gates` (RECOMMENDED, not included by default).
