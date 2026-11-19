# Secure Development Awareness Program

> **How to use:** Copy this plan, replace `<PLACEHOLDERS>` and example numbers with your own, pick the learning path per role (`learning-path-matrix.csv`), run the modules, and track results in `completion-tracker.csv`. This is a recommended model for Contoso Ltd., not a statement of what any organization has implemented. Review with your HR, legal and security teams before adopting.

## Purpose
Give everyone who builds or runs software the practical knowledge to prevent common vulnerabilities, using short sessions with hands-on exercises.

## Audiences

| Audience | Focus |
|----------|-------|
| Developers | Secure coding, injection, authentication, access control, secrets, review |
| QA | Test design for security, OWASP lists, access control tests, review checklist |
| Architects | Threat modeling, access control, cryptography, supply chain, privacy |
| Product owners | Risk awareness, OWASP overview, threat modeling outcomes, privacy, AI risks |
| DevOps / platform | Secrets, containers, IaC, CI/CD, supply chain, logging |

## Format
- 17 modules, 40 minutes each (see module files in this folder), live or recorded
- Each module: objectives, agenda, key takeaways, hands-on exercise, 5-question quiz
- Quiz bank with 85 questions for rotating assessments (`quiz-bank.csv`)
- Security champions in each team (see `champions-program-guide.md`)

## Cadence (examples)

| Activity | Frequency |
|----------|-----------|
| Onboarding path (modules 01, 02, 07) | Within 30 days of joining |
| Role-based path | Within 6 months |
| Refresher quiz (10 random questions) | Quarterly |
| Module refresh | Every 12 months |
| Champions meetup | Monthly, 45 minutes |
| Capture-the-flag or lab day | Twice a year |
| Content review | After each significant incident or yearly |

## Completion KPIs (example targets)

| KPI | Target | Source |
|-----|--------|--------|
| Onboarding path completed in 30 days | 95% | Tracker |
| Role-based path completed in 6 months | 90% | Tracker |
| Average quiz score | At least 80% | Tracker |
| Pass rate at first attempt | At least 75% | Tracker |
| Feedback score (1-5) | At least 4.0 | Feedback form |
| Teams with an active champion | 100% | Champion roster |
| Reduction in repeat finding types after training | 20% year over year | Findings log |

## Roles

| Role | Responsibility |
|------|---------------|
| Program owner (security) | Plan, content, KPIs, reporting |
| Team lead | Release time, completion follow-up |
| Champions | Local coaching, feedback to content |
| HR / people team | Records and onboarding integration |

## Contents

| File | Purpose |
|------|---------|
| learning-path-matrix.csv | Role by module (required / optional) |
| 01-secure-coding-fundamentals.md | Module 01 |
| 02-owasp-top-10-web.md | Module 02 |
| 03-owasp-api-top-10.md | Module 03 |
| 04-input-validation-and-injection.md | Module 04 |
| 05-authentication-and-session-management.md | Module 05 |
| 06-access-control.md | Module 06 |
| 07-secrets-management.md | Module 07 |
| 08-cryptography-basics.md | Module 08 |
| 09-dependency-and-supply-chain-risk.md | Module 09 |
| 10-container-and-kubernetes-security.md | Module 10 |
| 11-iac-security-terraform.md | Module 11 |
| 12-ci-cd-pipeline-security.md | Module 12 |
| 13-threat-modeling-stride.md | Module 13 |
| 14-secure-code-review-checklist.md | Module 14 |
| 15-logging-and-error-handling.md | Module 15 |
| 16-llm-ai-application-security.md | Module 16 |
| 17-privacy-by-design.md | Module 17 |
| quiz-bank.csv | 85 questions with answers |
| completion-tracker.csv | Attendance and completion tracker |
| champions-program-guide.md | Security champions program |
| feedback-form.md | Post-session feedback form |

## Exercise safety rules

1. Use a lab or sandbox only.
2. Use fictional data and placeholder credentials.
3. Vulnerable snippets are intentionally simplified and are labeled; never copy them into real code.
4. Do not test against systems you do not own or have written permission to test.

Related: redhat-model, secure-sdlc, threat-modeling.
