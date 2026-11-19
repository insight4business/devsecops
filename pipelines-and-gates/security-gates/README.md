# Security gates (RECOMMENDED, optional)

> **Status: recommended models.** These files are templates you may adopt. They are **not** a description of controls that exist in any particular environment, and they are not wired into the Terraform pipelines by default. Test each gate on a sandbox repository, tune it, then enforce it.

| Gate | File | Catches | Typical blocking threshold |
|------|------|---------|----------------------------|
| Secrets | [gate-secrets-gitleaks.yml](./gate-secrets-gitleaks.yml) | keys, tokens, passwords in code and history | any confirmed finding |
| SAST | [gate-sast-codeql.yml](./gate-sast-codeql.yml), [gate-sast-semgrep.yml](./gate-sast-semgrep.yml) | insecure code patterns | High and Critical (Semgrep: severity ERROR) |
| SCA | [gate-sca-dependency-audit.yml](./gate-sca-dependency-audit.yml) | vulnerable dependencies | High and Critical with a fix available |
| IaC scan | [gate-iac-checkov-trivy.yml](./gate-iac-checkov-trivy.yml) | insecure Terraform and YAML | High and Critical; Medium as warning |
| DAST | [gate-dast-zap-baseline.yml](./gate-dast-zap-baseline.yml) | exposed headers, cookies, passive web issues | rules set to FAIL in the ZAP rules file |
| Azure Pipelines | [azure-pipelines-gates.yml](./azure-pipelines-gates.yml) | equivalent job snippets for secrets, IaC and SCA | same as above |

## How to introduce a gate without blocking everyone
1. **Observe**: run in report-only mode (`continue-on-error`, `--soft-fail`, `|| true`) for two weeks and read the results.
2. **Baseline**: record the existing findings (gitleaks baseline file, Semgrep and Checkov baselines or suppressions with a reason and an owner). New findings fail; old ones are tracked in the triage template (`../../secure-sdlc/code-scanning-triage-template.md`).
3. **Enforce on new code**: block pull requests at the threshold in the table. Start with the highest severity and secrets.
4. **Tighten**: lower the threshold (Medium) when the backlog is under control.
5. **Review exceptions** monthly. Every exception has an ID, a justification, an owner and an expiry date.

## Threshold guidance
- **Secrets**: zero tolerance. A finding means the secret is compromised: rotate first, then clean the history.
- **SAST**: block High and Critical. Treat Medium as a ticket with an SLA; Low as information.
- **SCA**: block High and Critical when a fixed version exists; for others, track with an SLA. Consider reachability before declaring a false positive.
- **IaC**: block High and Critical (public storage, open security groups, missing encryption). Document each skipped check next to the code.
- **DAST**: baseline scans are passive and safe for a staging site you own. Authenticated or active scans need explicit written authorization and a test window.

## Operational notes
- Pin tool versions and verify checksums; unpinned security tools are a supply-chain risk of their own.
- Run gates on pull requests and on a nightly schedule (new vulnerabilities appear without code changes).
- Never print findings that include secret values; use redaction.
- Do not run DAST against systems you do not own or are not authorized to test.
