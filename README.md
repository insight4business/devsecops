# DevSecOps

CI/CD pipeline templates (Validate, Plan, Apply), Terraform modules and standard, threat modeling, secure SDLC checklists and pre-commit hooks.

_Templates in this folder are generic and rebuilt from delivery experience. All examples are fictional (Contoso Ltd.). Nothing here states that a control is deployed anywhere; security gates are labeled as recommended models._

## Find by sub-process

| Domain | Start here | Content |
|---|---|---|
| Access control and secrets | [access-control-and-secrets](./access-control-and-secrets) | Pointers to related templates |
| Information classification | [information-classification](./information-classification) | Pointers to related templates |
| Cryptography | [cryptography](./cryptography) | Pointers to related templates |
| Secure operations | [secure-operations](./secure-operations) | Pointers to related templates |
| Log management | [log-management](./log-management) | Pointers to related templates |
| Vulnerability management | [vulnerability-management](./vulnerability-management) | Pointers to related templates |
| Network security | [network-security](./network-security) | Pointers to related templates |
| Application monitoring | [application-monitoring](./application-monitoring) | Pointers to related templates |
| Incident management | [incident-management](./incident-management) | Pointers to related templates |
| Secure development lifecycle | [secure-development-lifecycle](./secure-development-lifecycle) | [secure-sdlc](./secure-development-lifecycle) |
| Threat modelling | [threat-modelling](./threat-modelling) | threat-modelling |
| Infrastructure as code | [infrastructure-as-code](./infrastructure-as-code) | [terraform](./infrastructure-as-code/terraform) |
| Pipelines and gates | [pipelines-and-gates](./pipelines-and-gates) | [pipelines](./pipelines-and-gates) |
| Containers and Kubernetes | [containers-and-kubernetes](./containers-and-kubernetes) | [redhat-model](./containers-and-kubernetes/redhat-model) |
| Training | [training](./training) | [secure-dev-training](./training/secure-dev-training) |

## Contents

| Area | Folder | What you get |
|------|--------|--------------|
| Terraform modules | [terraform/modules](./infrastructure-as-code/terraform/modules) | `aws-private-s3`, `aws-hardened-ec2`, `azure-vnet-baseline`, `azure-storage-diag`, `aws-iam-oidc-pipeline-roles`, `aws-cloudtrail-baseline` (each with README and example) |
| Terraform standard | infrastructure-as-code/terraform/standard/terraform-standard.md | 13-section standard: structure, state, versions, modules, secrets, tags, PR flow, drift, cost, checklist |
| Pipelines | [pipelines](./pipelines-and-gates) | Azure Pipelines and GitHub Actions: Validate, Plan (read-only), Apply (approved, write), OIDC |
| Security gates | [pipelines/security-gates](./pipelines-and-gates/security-gates) | Recommended, optional: gitleaks, CodeQL/Semgrep, dependency audit, checkov/trivy, ZAP baseline |
| Threat modeling | threat-modelling | STRIDE template (markdown and CSV), fictional web app example, workshop guide |
| Secure SDLC | [secure-sdlc](./secure-development-lifecycle) | Checklist by phase, findings triage template, gap analysis (66 practices, 7 categories, CWE mapped) |
| Pre-commit | [pre-commit](./pre-commit) | Example hooks: gitleaks, terraform fmt/validate, yamllint |
| DevSecOps model (Red Hat-style) | [redhat-model](./containers-and-kubernetes/redhat-model) | 15 files: lifecycle overview, maturity model and self-assessment, build / deploy / run controls, Kubernetes and OpenShift hardening checklist, admission and NetworkPolicy YAML, Ansible baseline, compliance-as-code mapping, RACI, metrics, 30/60/90 roadmap, tool mapping |
| Secure development training | [secure-dev-training](./training/secure-dev-training) | Awareness program: plan, learning-path matrix, 17 module outlines with exercises and quizzes, 85-question quiz bank, tracker, champions guide, feedback form |

## How to use

1. Copy the template you need.
2. Replace every `<PLACEHOLDER>` with your own values.
3. Test in a sandbox account or subscription before real use.
4. Review with your own legal and security teams before adopting.

## Module quality bar
Typed and described variables, `validation` where useful, secrets without default and `sensitive`, pinned provider versions, secure defaults, placeholders only. Run `terraform fmt -check` and `terraform validate` (after `init`) before use.

## License
Apache License 2.0. See [LICENSE](./LICENSE).
