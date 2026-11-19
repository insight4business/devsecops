# Secure Development Lifecycle

Security activities across the software lifecycle.

Content lives in secure-sdlc: checklist by phase, scanning triage template and gap analysis. Training is in secure-dev-training.


# Secure SDLC

| File | Use |
|------|-----|
| secure-sdlc-checklist.md | Checklist by phase: requirements, design, implementation, verification, release, operations, retirement |
| code-scanning-triage-template.md and .csv | Severity, SLA, status and decision for scanner findings |
| gap-analysis-template.csv | Secure coding practices gap analysis with CWE references |

## Gap analysis
Columns: `id`, `practice`, `cwe`, `status`, `owner`, `evidence`.

The `id` prefix is the category:

| Prefix | Category |
|--------|----------|
| DP | Data Protection |
| SM | Session Management |
| IO | Input/Output |
| EL | Error and Logging |
| CO | Config and Operations |
| AU | Authentication |
| AC | Access Control |

Suggested `status` values: `Not assessed`, `Implemented`, `Partial`, `Not implemented`, `Not applicable`. Put a link or a short description of proof in `evidence` (a test, a configuration, a review record). The practices are written in our own words and mapped to public CWE identifiers; adapt them to your stack.
