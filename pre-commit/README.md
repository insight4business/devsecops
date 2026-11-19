# Pre-commit

Example hooks that catch problems before they reach the repository.

| Hook | Purpose |
|------|---------|
| `gitleaks` | blocks commits that contain secrets |
| `detect-private-key` | blocks private key files |
| `terraform_fmt`, `terraform_validate` | formatting and syntax |
| `yamllint` | consistent pipeline and workflow YAML |

## Use
1. Copy `.pre-commit-config.yaml` and `.yamllint.yaml` to the root of your repository.
2. `pip install pre-commit`, then `pre-commit install`.
3. Run `pre-commit run --all-files` once and fix the findings.

## Notes
- Hooks run on the developer machine and can be bypassed (`--no-verify`). The same checks must run in the pipeline.
- Pin hook revisions and update them deliberately (`pre-commit autoupdate`, then review).
- If gitleaks reports a real secret, rotate it first, then remove it from history.
