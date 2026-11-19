# Pipelines and Gates

Content lives in pipelines: Azure Pipelines, GitHub Actions and security gates.


# CI/CD pipelines

| Folder | Contents |
|--------|----------|
| [azure-pipelines](./azure-pipelines) | Validate, Plan (read-only identity), Apply (write identity, Environment approval), manual Destroy on the development branch |
| [github-actions](./github-actions) | Same flow with OIDC and Environment protection |
| [security-gates](./security-gates) | **Recommended, optional** gates: secrets, SAST, SCA, IaC scan, DAST |

Common principles:
- No static cloud credentials: OIDC federation.
- Separate identities for plan (read) and apply (write).
- The approved plan is the plan that is applied.
- Production changes need a human approval that is not the author.
- Destroy is manual, parameterized and limited to development.
