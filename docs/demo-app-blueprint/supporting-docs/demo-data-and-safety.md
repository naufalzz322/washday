# Demo Data and Safety

**What this covers:** Safe data, credentials, integrations, permissions, and disclosure rules for a demo environment.
**Read this when:** Creating fixtures, seeded accounts, screenshots, recordings, sandbox integrations, reset scripts, or sharing the demo.
**Last updated:** 2026-11-02

## Data classification

Use synthetic or explicitly approved sandbox data by default. Record the data class, source, owner, retention, and deletion method. Do not copy live client records into fixtures, logs, screenshots, recordings, test databases, or agent context.

| Data or integration | Class | Source/owner | Environment | Retention/deletion | Approval/evidence |
|---|---|---|---|---|---|
| `<fixture/service>` | `<synthetic/approved/other>` | `<owner>` | `<local/sandbox>` | `<rule>` | `<record>` |

## Credentials and access

- Keep credentials outside source control and fixture files; use an approved secret store or local mechanism.
- Use disposable demo accounts with the minimum roles needed for the walkthrough. Never share passwords in the walkthrough document.
- Separate demo credentials, tokens, databases, buckets, queues, and third-party sandboxes from production and customer environments.
- Deny production credentials and production endpoints to seed/reset scripts and agent workflows.
- Record who can create, rotate, revoke, and recover demo access.

## External effects

List every external integration and whether it is real, sandboxed, mocked, or simulated. Document writes, messages, emails, payments, files, webhooks, analytics, and rate limits. Prefer no-op or sandbox behavior. Require explicit human approval before enabling an effect that reaches a real external system.

## Sharing and disclosure

Before sharing a demo, check that screenshots, recordings, logs, URLs, domains, account names, error messages, and sample data reveal no secrets, personal data, client-confidential information, or internal-only instructions.

Keep two disclosure surfaces distinct:

- Presenter/project notes list all limitations, mocks, and disabled features so the demo is represented accurately.
- User-facing UI uses natural product language on routine pages, while a concise information/policy page and relevant action/confirmation points explain limitations that affect user expectations. Presenter notes do not replace disclosures needed by the person using the UI.

Do not repeatedly label ordinary navigation or product content “demo,” “sample,” “fixture,” or “simulated.” Do not imply an external effect or live data when only local or synthetic state changes. For example, if no payment or shipment occurs, say so before order submission and in the resulting order/status view; do not show fixture stock as live availability. Follow `02_design-md.md` for the UI copy acceptance checks.

## Incident response

If a secret, live data, or unintended external effect is exposed: stop sharing and execution, revoke or rotate affected access, preserve evidence without copying sensitive content, notify the responsible human owner, and record the corrective action. Do not hide the incident by rewriting logs or fixtures.

## Questions to resolve

- Is all demo data synthetic or explicitly approved?
- Which credentials, endpoints, and integrations are sandbox-only?
- Which actions are read-only, mocked, no-op, or real external effects?
- Who approves sharing, rotates access, and handles an exposure?
- What must be deleted after the demonstration?
