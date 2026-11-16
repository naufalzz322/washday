# Operations and Observability

**What this covers:** Environments, configuration ownership, observability, alerts, incident response, demo-environment readiness, rollback, and recovery.
**Read this when:** Defining how the system runs, adding logs or metrics, preparing a shared demo environment, investigating an incident, or reviewing operational readiness.
**Last updated:** 2026-11-02

This file is a template. It contains no stack choices. `ASK:` marks questions for the project's writer.

Principle: document operational behavior that cannot be inferred safely from code. Keep production secrets and sensitive operational data in approved platform systems, not in the repository or agent workspace.

## Environment matrix

Create one row for each environment and state its purpose, data policy, access owner, deployment owner, and URL or platform reference.

| Environment | Purpose | Data and credentials | Deploy owner | Rollback reference |
|---|---|---|---|---|
| `<local/dev>` | `<development>` | `<fake or sandbox data>` | `<role>` | `<runbook>` |
| `<demo-preview>` | `<shared demo or presentation>` | `<synthetic/sandbox data>` | `<role>` | `<runbook>` |

Staging should be sufficiently representative for the checks it is used to accept. Never copy production personal data into development, staging, or an agent session.

Document how environments are provisioned, updated, monitored for configuration drift, access-reviewed, and retired. State which environments are ephemeral (such as preview/test) and how long they live. Define the allowed path for promoting the same identified build artifact between environments; record where rebuilds are unavoidable and how equivalence is proven. Infrastructure ownership and approved provisioning procedures must be explicit.

## Configuration ownership

- Keep a versioned, non-secret configuration schema and an `.env.example`-style placeholder file when the stack uses environment variables.
- Record each setting's owner, purpose, allowed environments, safe default, and change approval path.
- Store secrets in the platform or CI secret store. Use separate credentials per environment and least-privilege roles.
- Production configuration changes are reviewed, auditable, and reversible. Agents do not access or modify production secrets.
- Link rotation and leak-response procedures from `docs/runbooks/secret-rotation.md` and `docs/runbooks/security-incident.md` when applicable.

## Observability

Define the minimum signals for each deployable part:

| Signal | Required information | Restrictions |
|---|---|---|
| Logs | Structured event, severity, timestamp, request or trace ID, safe context | No secrets, tokens, card data, or unnecessary personal data |
| Metrics | Availability, request rate, errors, latency percentiles, saturation, and key business failures | Define units, labels, owner, and retention |
| Traces | Cross-service or external-call boundaries, duration, outcome, trace ID | Redact sensitive attributes; sample intentionally |
| Health checks | Liveness and readiness behavior, dependencies, timeout | Do not expose secrets or detailed internals |

`ASK:` which dashboards, retention periods, alerting system, and trace or log correlation fields the project uses. Every critical alert links to an owner and a runbook.

## Alerts and incident response

- Alert on user impact or imminent risk, not on every log message. Each alert has a severity, owner, threshold, evaluation window, and runbook.
- Define escalation, incident roles, communication channels, status updates, and post-incident review. Do not place secrets or personal data in incident channels.
- Security incidents follow `docs/runbooks/security-incident.md`. Record only the operational details needed to respond.
- `ASK:` the service-level targets, escalation timing, support hours, and legal or contractual notification deadlines.

## Shared-demo environment readiness checklist

Before sharing or presenting from a shared environment, confirm the applicable items:

- Ownership, on-call or escalation, dashboards, actionable alerts, and runbooks exist.
- Performance targets in `docs/nfr.md` were measured with the agreed workload and environment.
- Accessibility, security, walkthrough, and reset/recovery checks are complete where applicable.
- Deployment, migration, feature-flag, rollback, and recovery procedures were reviewed.
- Synthetic/approved data, access, dependencies, and configuration changes are understood by the owner.
- Recovery and reset ownership are explicit; record a recovery target only when the shared demo needs one.

## Deploy, rollback, and recovery

- Release procedures are environment-specific and human-approved for production.
- Prefer reversible changes and expand/contract data migrations. Never edit an applied migration; destructive changes require human approval.
- Define what triggers rollback, who authorizes it, how traffic or flags are changed, and how data compatibility is preserved.
- If the demo stores state that matters between sessions, document backup/restore or a safe rebuild path and test it. A recovery claim without a test is not verified.
- Agents never deploy to production, run production migrations, or handle live credentials.
- This section covers operational principles. The walkthrough/reset document owns presentation baseline and reset evidence; deployment rollback is not a substitute for recovering corrupted or lost demo state.

## Questions to ask when instantiating

- Which environments exist, who owns them, and what data is allowed in each?
- Which settings are configuration versus secrets, where are they stored, and who may change them?
- What logs, metrics, traces, dashboards, alerts, and runbooks are required?
- What are the availability, latency, recovery-time, and recovery-point targets?
- Who approves releases, rollbacks, migrations, and incident communications?
