# AGENTS.md Skeletons

**What this covers:** Ready-to-fill skeletons for the root `AGENTS.md` and the per-app `AGENTS.md`, with the five standard sections (project overview, build and test commands, code style, testing, security) plus Boundaries and Definition of done, and the conventions that keep them short.
**Read this when:** Writing or reviewing a root or app `AGENTS.md`, or filling in commands and code style rules.
**Last updated:** 2026-11-07

This file is a **template**. Fill angle-bracket placeholders (`<...>`) from decisions in the project-root `PROJECT_INTAKE.md`. `TODO(decide)` marks an open decision. No stack is assumed.

The blocks for Boundaries, Definition of done, Testing, Documentation, and Progress are copied from `04`, `05`, `07`, and `01`, where they are maintained. If you change one, change it there first and re-copy it here.

---

## Conventions that keep these files short

1. **Fixed command verbs everywhere:** `setup`, `run`, `build`, `test`, `lint`, `format`, `codegen`. Every app answers the same verbs, so agents never guess.
2. **List scripts, not raw tool flags.** Expose commands as package scripts or documented verbs. Tool flags change; script names are yours.
3. **Production scripts are named `deploy:prod` and `migrate:prod`** (or similar) so the tool's permission config can deny them by name (see `07`, section 2). They are listed as "humans only".
4. **Code style has two layers.** Tool-enforced rules collapse to one line (run lint and format; don't hand-fix style). The markdown only holds conventions no tool can check, about 5 lines per app.
5. **Every section is short and points to a doc** for detail. Security and Testing are a few lines each, not essays.
6. **Mark unknowns `TODO(decide)`** and list what blocks each one (see the end of this file), so placeholders are visible instead of guessed.
7. **Size budget:** root 150 lines or fewer, each app file 80 or fewer.

---

## Root `AGENTS.md` skeleton

````md
# <Project name>

## Project overview
<2-4 lines: what this system/demo is and who uses it.>

## Requirements and phase gates
- Before planning a prototype, system design, frontend, or optional backend, read the copied blueprint's `supporting-docs/requirements-discovery-and-readiness.md` and check the project `PROJECT_INTAKE.md`.
- Inspect the request, conversation, brief, and existing decisions first. Ask one focused question at a time for a missing audience, service model, role, walkthrough feature, boundary, disclosure, reset rule, or acceptance criterion; never infer the standard features of a product category.
- Track answers with stable IDs, source, status, gate, owner, and approval date. A blocking `TODO(decide)`, conflict, or pending recommendation means stop and ask.
- Read back the confirmed audience/outcome/walkthrough, included and excluded features, assumptions, blockers, safety/disclosure boundaries, and next bounded phase. Proceed only after the owner's explicit confirmation; reopen the affected gate if scope changes.
<N> projects in one repo: <app> (<audience>, <stack>), <app> (...), <app> (...).
How they relate: <for example, all clients call the API; the API description is the contract>.
Business terms, roles, and lifecycles: docs/domain.md.

## Repo map
| Path | What | Stack |
|---|---|---|
| apps/<app> | <what it is> | <stack> |
| packages/<package> | <what it shares> | <language> |
| packages/api_contract | Generated API description | <format> |

## Commands
Same verbs everywhere. Production commands exist for humans only; never run them.
| Part | setup | run | build | test | lint / format | codegen |
|---|---|---|---|---|---|---|
| <workspace root, if any> | `<cmd>` | | | | | |
| <app> | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` / `<cmd>` | `<cmd>` |
| <api> | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` | `<cmd>` / `<cmd>` | `<cmd>` |
| <api> (staging only) | | | `<deploy:staging cmd>` | | `<db migrate cmd>` (local/staging) | |
Humans only: `deploy:prod`, `migrate:prod`.

## Code style
- Formatting and lint are enforced by tools (commands above). Run them before finishing; don't hand-fix style.
- Names in code, DB, and API use <language>. User-facing text comes from localization files; never hardcode strings, colors, or sizes (tokens live in <path>).
- Check packages/ for an existing component or helper before writing a new one.
- Never hand-edit generated files (the API description, generated clients, generated token outputs). Regenerate with the codegen command.
- App-specific conventions: see each app's AGENTS.md.

## Testing
- Levels: unit (fast, no network/DB), integration (real DB, fake third parties), e2e (few full journeys). Definitions in docs/testing.md.
- While working, run the narrowest relevant tests. Before finishing, run the full suite of each app/package you changed, plus consumers of any changed shared package.
- Run e2e only when asked or when you changed a critical flow (<list>).
- New behavior or bug fix -> add a test (bug fix: failing test first). Include the spec ID in the test name.
- Never delete, skip, or weaken a failing test to pass. If a test looks wrong, say so.
- Money, inventory, and payment logic need integration tests against the real test DB, not mocks.
- Report only failing tests and the first error; don't paste full logs.

## Security
- Never read, print, log, or commit secrets. Local env files hold dev and sandbox values only.
- Never log personal data or payment data. If the project takes payments: never store, log, or collect card numbers; use the gateway's hosted flow or SDK only.
- Validate every input on the server with the route's schema and reject unknown fields. Use the data layer's parameterized queries; never build queries from strings.
- Every API route checks authentication, role, and object ownership. A verified, idempotent webhook, not the client, decides that a payment succeeded.
- Adding a dependency is "ask first": verify the package exists and is maintained.
- Details: docs/security.md (index).

## Boundaries
Always: run the relevant tests before finishing; follow the definition of done; use sandbox credentials only.
Ask first: adding dependencies, database schema changes, CI/CD changes, deleting files outside the task, changing a spec marked "agreed".
Never: deploy to production; run migrations against production; use live third-party credentials; store, log, or collect card numbers; read, print, or commit secrets; edit generated files by hand.

## Parallel work (only if you run agents in parallel worktrees)
- You may be one of several agents, each in its own git worktree. Stay inside your worktree.
- Use the port and test database name from your worktree's env. Never share them.
- Update docs/progress.md only for the item you were assigned.
- For provider limits and automatic compaction, follow `docs/agent-loop-and-harness.md`; a task checkpoint preserves progress but does not shrink the current API request.
- For long tasks, save a separate checkpoint at `<approved handoff threshold>` to `<approved temporary checkpoint path>`; resume only after rereading it and verifying live state.

## Definition of done
- Relevant tests pass (levels in docs/testing.md); full suite for each app/package changed.
- Analyzer, linter, and formatter are clean.
- Behavior changed -> the owning doc and spec are updated in the same change.
- Routes changed -> the API description is regenerated and committed.
- Work matches a tracked item -> docs/progress.md updated.
- Auth, payments, or personal data touched -> security self-check against docs/security.md and a human reviewer.
- UI changes -> applicable accessibility checks pass; performance-sensitive changes meet the accepted target in docs/nfr.md.
- Demo readiness -> setup, primary walkthrough, safe data/reset, and applicable check evidence are recorded in project-owned demo docs; for UI, ordinary pages use natural product language, while relevant action/result points disclose non-live behavior truthfully and fixture data is not presented as live.
- A human owner reviews the demo evidence; agents never claim production readiness, legal approval, or external approval.
- Agent skills, loops, delegation, and evaluation follow `docs/agent-skills.md`, `docs/agent-loop-and-harness.md`, `docs/multi-agent-coordination.md`, and `docs/agent-evaluation-and-red-teaming.md`; missing evidence or failed safety gates blocks approval.
- Commit messages follow Conventional Commits with an app scope.

## Demo readiness
- The primary walkthrough starts from the documented baseline and has actual run evidence; missing evidence is not a pass.
- Demo data, credentials, external effects, mocked behavior, limitations, reset safety, and recovery ownership are documented in the routed demo docs.
- Production access, live credentials, destructive changes, legal/compliance decisions, and scope expansion remain human-gated.

## Documentation and progress
- Never hand-write endpoint docs. Change the route's schema (summary, description, examples, error responses), regenerate the API description, and commit it.
- Don't open the full API description; search it for the path you need.
- When behavior changes, update the one doc that owns it, in the same change. Don't copy facts into several docs.
- Demo walkthroughs: you may draft and update scenarios, but record actual run results and limitations only after someone runs them; never claim a human approval.
- Humans read README.md. Link to it; don't duplicate it here.
- After finishing work that matches an item in the "Current" section of docs/progress.md, update that item's status in one line. Don't add entries for refactors, typo fixes, or small tweaks. If unsure, don't edit the file.

## Commits
Conventional Commits with an app scope: `feat(<app>): ...`, `fix(<app>): ...`. Never edit CHANGELOG.md (generated).

## Precedence
Code and generated files beat markdown. An app file beats this file. An "agreed" spec or a recorded decision beats the source requirements document.
If a doc and the code disagree, trust the code and flag the doc.

## Where to find things (read only what the task needs)
| If you're working on... | Read |
|---|---|
| Before a new prototype, design, feature, or system change | Copied blueprint `supporting-docs/requirements-discovery-and-readiness.md` and project `PROJECT_INTAKE.md` |
| Building a feature (per app) | apps/<app>/docs/specs/<feature>.md |
| Anything touching the API | docs/api-contract.md (conventions); the generated description is the endpoint reference |
| Security (auth, validation, payments, privacy, secrets) | docs/security.md (index) |
| A major subsystem (<topic>) | docs/<topic>.md |
| Domain terms, lifecycles | docs/domain.md |
| Performance-critical code | docs/nfr.md |
| Operations, observability, and readiness | docs/operations.md |
| Demo walkthrough, reset, recovery, or limitations | docs/demo-walkthrough-and-reset.md |
| Demo data, credentials, integrations, or sharing | docs/demo-data-and-safety.md |
| Managing skills, agent loops, or multi-agent work | docs/agent-skills.md, docs/agent-loop-and-harness.md, docs/multi-agent-coordination.md |
| Evaluating or red-teaming agent behavior | docs/agent-evaluation-and-red-teaming.md |
| Writing or fixing tests | docs/testing.md |
| Building or changing UI | DESIGN.md (and the app's own) |
| Writing or updating demo walkthroughs | docs/demo-walkthrough-and-reset.md |
| Deploy, rollback, restore | docs/runbooks/ |
| Picking up or planning work | docs/progress.md (top section only) |
| Why a past decision was made | docs/decisions/ |

Do not read docs unrelated to the current task. Do not read CHANGELOG.md or progress-archive.md unless asked.
Before working in an app, list its directory so its AGENTS.md loads.
````

---

## App `AGENTS.md` skeleton

````md
# <app> (<stack>, <audience>)
Extends the root AGENTS.md. Rules here win on conflict.

## Overview
<2 lines: what this app does.> Depends on: <packages>.

## Decisions
- <Decision 1, e.g. state management>: TODO(decide). <One project-specific rule.>
- <Decision 2, e.g. routing or navigation>: TODO(decide). Defined in <path>.
- Structure: <layout>. Reference feature: <path>.
- Error handling: TODO(decide) one pattern, used everywhere.

## Commands
| Verb | Command |
|---|---|
| run | `<cmd>` |
| build | `<cmd>` |
| test | all: `<cmd>` / one file: `<cmd> <path>` / by name: `<cmd> <name>` |
| lint / format | `<cmd>` / `<cmd>` |
| codegen | `<cmd>` (if used) |

## Code style (what tools can't enforce)
- Data access only through the shared API client. No hand-written network calls in features.
- Colors, spacing, and text styles come from design tokens. User-facing text comes from localization files.
- UI components stay presentational. Logic lives in <layer>.
- <1-3 more app-specific conventions>

## Testing
- Integration (<prerequisites, e.g. emulator, browser, DB>): `<cmd>`
- <Where tests live.> Fakes live in <path>. No real network in unit tests.
- Re-run this app's tests after changes in <shared packages>.

## Gotchas
- <non-obvious things that have caused mistakes>

## Read when
| Building or changing a feature | docs/specs/<feature>.md |
| Adding a feature or screen | docs/architecture.md |
| Changing UI | root DESIGN.md and this app's DESIGN.md |
````

### Variants (only the differences)

- **Mobile or field app:** gotchas add connectivity and offline behavior. UI differences live in its `DESIGN.md` (touch targets, contrast).
- **Web app:** one stated rule for where code runs (server versus browser) if the framework mixes them (`TODO(decide)`), authorization enforced on the server and not only by hiding UI, and user-facing text through the i18n files.
- **API app:**
  - Commands: `dev`, `test`, `lint`, `format`, a command that exports the API description, data-migration commands (local and staging only), and `deploy:staging`. `deploy:prod` and `migrate:prod` are humans only.
  - Code style: every route is defined with its schema. Handlers stay thin and call services, and services use the data layer. Money as integers in the smallest unit.
  - Security: authentication and role scoping on every route, webhook signature verification and idempotency, no personal data in logs.
  - Gotchas: runtime limits of the hosting platform, and how the app connects to its database.

---

## Placeholders and what blocks them

| Placeholder | Blocked by (a project decision recorded in `PROJECT_INTAKE.md`) |
|---|---|
| Stack names, `<cmd>` entries | Stack per part, package manager, workspace tool |
| App decisions (state, routing, errors, structure) | Framework-level choices per app |
| Test commands, test DB setup | Test tools and test database approach |
| `codegen` and export commands | API contract direction, token source |
| Database connection note | Database and hosting |
| Deploy commands, CI jobs, PR template | Git host, CI, and hosting |
| Critical flows for e2e | Which flows are business-critical |
