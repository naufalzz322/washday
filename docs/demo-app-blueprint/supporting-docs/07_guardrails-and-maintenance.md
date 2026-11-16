# Guardrails and Maintenance

**What this covers:** Agent boundaries and permissions, secrets handling, definition of done, keeping docs fresh, security and performance docs, tooling-enforced style, release runbooks, skills hygiene, PR template, and how to validate the structure.
**Read this when:** Setting up agent permissions, writing the Boundaries or Definition of done blocks, reviewing how docs are kept current, or auditing this setup.
**Last updated:** 2026-11-07

This file is a **template**. It contains no stack choices. `ASK:` marks questions for the project's writer.

---

## 1. Boundaries (block for root `AGENTS.md`)

The structure tells agents what to read. This block tells them what they may do.

```md
## Boundaries
Always: run the relevant tests before finishing; follow the definition of done; use sandbox credentials only.
Ask first: adding dependencies, database schema changes, CI/CD changes, deleting files outside the task, changing a spec marked "agreed".
Never: deploy to production; run migrations against production; use live third-party credentials; store, log, or collect card numbers; read, print, or commit secrets; edit generated files by hand.
```

Written rules are guidance. Permissions (next section) are enforcement.

---

## 2. Permissions and approvals (tool-agnostic)

Written rules are guidance; the tool's permission mechanism is enforcement. Syntax and verified behavior for each tool are in `09_tool-profiles.md`.

- **Deny reading secret files:** `.env*` (allow `.env.example`), any other local secret files the stack uses (`ASK:` which; some frameworks use differently named files that default patterns won't match), and keys and signing files (`*.pem`, `*.key`, `*.jks`, `*.keystore`, `*.p12`, `*.mobileprovision`).
- **Require approval for shell commands by default**, and allow only safe ones (test, lint, format).
- **Deny production scripts by name** (`deploy:prod`, `migrate:prod`), so the patterns stay simple. Where a tool offers both ask and deny, use deny for must-never actions, because some modes auto-approve ask but still enforce deny (verified for one tool; check others in `09`).
- **Deny rules are a guard, not a vault.** An agent can sometimes read denied files through shell commands. Keep production secrets out of the working directory: use the platform's secret store and CI secrets, and keep only dev and sandbox values locally.
- **User-level configuration:** some tools keep permission settings outside the repo, so they can't be committed. Record the recommended settings in `09` and have each developer apply them.
- **Parallel worktrees:** carry only dev and sandbox env files into new worktrees (see `09`).

---

## 3. Definition of done (block for root `AGENTS.md`)

```md
## Definition of done
- Relevant tests pass (levels in docs/testing.md); full suite for each app/package changed.
- Analyzer, linter, and formatter are clean.
- Behavior changed -> the owning doc and spec are updated in the same change.
- Routes changed -> the API description is regenerated and committed.
- Work matches a tracked item -> docs/progress.md updated.
- Auth, payments, or personal data touched -> security self-check against docs/security.md and a human reviewer.
- UI changes -> applicable accessibility checks pass; performance-sensitive changes meet the accepted target in docs/nfr.md.
- Commit messages follow Conventional Commits with an app scope.
```

---

## 4. Keeping docs fresh

**Precedence rule** (state it in root `AGENTS.md`):

- Code and generated files beat markdown.
- An app file beats the root file.
- An "agreed" spec or a recorded decision beats the source requirements document.
- If a doc and the code disagree: trust the code, flag the doc, and fix it in the same change when it's in scope.

**Doc-check script** (`scripts/check-docs`, run in CI). Fail on:

- A path in a router table that doesn't exist
- A docs file missing the two-line "What this covers / Read this when" header
- A spec file containing an ID with a different app's prefix (enforces one app per spec)

Warn on size: root `AGENTS.md` over about 150 lines, other `AGENTS.md` and docs over about 80.

**Maintaining `AGENTS.md`:**

- Treat it like code: change it through pull requests.
- Add a rule only after the same mistake happens twice.
- Delete rules that are obsolete or that a linter or formatter already enforces.
- Facts about tool behavior carry a "verified <date>" note. Re-verify when the tool is upgraded.

---

## 5. Security and privacy

The standards, rules, and file layout are in `10_security-standards.md`. In the repo: `docs/security.md` is an index (OWASP rule table, core rules, links) and topic files in `docs/security/` cover input validation, auth and access, payments (if applicable), supply chain and secrets, privacy, platform hardening, and agent security. Each is about 80 lines or fewer.

CI security checks: dependency audit, secret scan, and optional static analysis. Runbooks: `security-incident.md` and `secret-rotation.md`.

Router row: "Anything security-related (auth, validation, payments, privacy, secrets) -> docs/security.md".

## 6. Performance budgets (`docs/nfr.md`)

A short table of targets taken from the demo scope, or proposed when the scope gives none. Read only when touching performance-critical code. Confirm the numbers with the demo owner before treating them as show-ready checks. `ASK:` for the expected load.

```md
| Metric | Target | Workload and environment | Measurement method | Review owner |
|---|---|---|---|---|
| <p95 latency, startup, throughput, or other> | <threshold> | <representative load and environment> | <tool, window, percentile> | <person or role> |
```

Do not treat an unrepresentative local timing as show-ready evidence. Record the result, date, build, workload, and environment with the performance review. Accessibility checks are defined in `docs/testing.md` and verified in the demo walkthrough where applicable.

## 7. Style through tooling, not prose

Formatting, lint, and analysis rules are enforced by tools. `ASK:` which formatter, linter, and type or static analyzer the stack uses, or recommend the standard ones for it. Docs list the commands only. No style rules in markdown that a tool already enforces. The few conventions no tool can check (about 5 lines per app) go in the app's `AGENTS.md` under "Code style" (see `08_agents-md-skeletons.md`).

## 8. Release runbooks (`docs/runbooks/`)

Include only the ones that apply:

- `release-mobile.md` (if there are mobile apps): build and signing (keys kept outside agent reach), store review lead time, phased rollout, link to the forced-update policy
- `release-api.md`: deploy per environment, rollback
- `migrations.md`: the data-migration process, never edit an applied migration, destructive migrations need human approval

Agents never run production steps (see Boundaries).

For a demo, record build identity, environment checks, walkthrough result, and reset/recovery verification in project-owned demo docs. Do not treat a deployment runbook or successful walkthrough as production-release approval.

## 9. Skills and agent-operations hygiene

Agent tools list skill names and descriptions in the agent's context (verified for some tools in `09`), so every skill description costs context. The full lifecycle is in `docs/agent-skills.md`; loop, delegation, and evaluation contracts are in the related agent-operations topic files.

- Keep skills few, one procedure each, with a precise trigger, scope, owner, version, review date, verification, and stop condition.
- Review skill content as code. Test happy path, invalid input, permission denial, interruption/resume, and failure before approval. Do not silently install, update, enable, or publish capabilities.
- Keep autonomous loops bounded and resumable. Pin the exact provider-route limit and configure automatic compaction below its effective input budget; do not treat a task checkpoint as API compaction or assume model-family metadata describes a proxy.
- Parallel workers need task contracts, one owner, isolated workspaces/resources, explicit locks, dependency order, and coordinator verification before merge.
- Run the evaluation/red-team scenarios before trusting a new or changed skill, harness, model/tool version, permission policy, or orchestration configuration.
- Starter set: add-endpoint, add-screen-or-page, write-migration, add-test, write-spec, write-demo-walkthrough; instantiate only those the project needs.

Checkpoint files contain no secrets. A task handoff preserves progress; automatic API compaction separately reduces conversation history. Record and verify both policies, and resume only after rereading the checkpoint and checking live state.

---

## 10. PR template

If the Git host supports pull request templates (`ASK:` which host and CI), add one mirroring the definition of done, plus "spec IDs touched".


## Demo-readiness gate

Before declaring a demo ready to show, confirm that setup and launch are reproducible, the primary walkthrough passes from a clean/reset state, demo data and credentials are safe, mocked or incomplete behavior is disclosed, applicable checks have evidence, and a human owner has a recovery path. Do not claim production readiness or external approval from this gate.

---

## 11. Validate the structure with real tasks

Run five real tasks: add an endpoint, add a screen or page, fix a bug in a critical flow, write a demo walkthrough, add a data migration. For each, note which files the agent opens, which rules it ignores, and what it asks you. Remove files and rules that weren't needed, and add router rows where the agent wandered. Repeat after major changes.

## 12. Blueprint vs. repo docs

- The numbered files in this template are a **blueprint**. Don't copy them into the repo as they are, or they'll drift. The repo gets the real `AGENTS.md`, `DESIGN.md`, and `docs/`.
- Keep generic skeletons (principles, templates, size limits, starter skills) separate from project facts (names, stack, IDs), so the project intake and team workflow fill in project-specific parts.
