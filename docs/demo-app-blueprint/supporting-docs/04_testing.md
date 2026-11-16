# Testing Requirements (unit, integration, e2e)

**What this covers:** Where testing rules live, how the three test levels are defined, rules agents must follow, and ready-to-use templates.
**Read this when:** Writing testing rules, `docs/testing.md`, or per-app test commands.
**Last updated:** 2026-11-02

This file is a **template**. It contains no stack choices. `ASK:` marks questions for the project's writer.

---

## Where each piece goes

| Location | Contents |
|---|---|
| Root `AGENTS.md` | About 10 lines of testing policy, plus one "run all tests" command per app. Some tools load nested files lazily (see `09_tool-profiles.md`), so the root needs at least the one-line commands |
| App `AGENTS.md` | That app's detailed commands (one file, one test by name), test folder layout, fakes, prerequisites |
| `docs/testing.md` | Strategy, level definitions, test data and DB reset, critical e2e journeys, CI summary. Read only when working on tests |
| `.agents/skills/` | Procedures: "add a unit test", "add an API integration test with the test DB", "add an e2e flow" |
| `packages/*/AGENTS.md` | Which consumers' tests to also run after a change |

---

## Define the three levels

Terminology varies (some frameworks call device-level UI flows "integration tests", while many teams call them e2e), so define the terms explicitly:

| Level | Scope | Dependencies | When it runs |
|---|---|---|---|
| Unit | One function, class, or component | Everything external faked (no network, DB, real clock) | Milliseconds; on every change |
| Integration | Several real parts together, for example an API route with a real test DB, or a screen with a fake API server | Real DB and framework, faked third parties | Seconds; before finishing a task, and in CI on every PR |
| E2E | A full user journey across the running system, third parties in sandbox | Everything real except third-party sandboxes | Minutes; only a few critical flows; CI on merge or nightly; locally only when asked |

**Test tooling per part.** `ASK:` which test tools the writer uses, or recommend tools that fit the stack and that the team already knows. Fill one row per part:

| Part | Unit | Integration | E2E | Run all | Run one |
|---|---|---|---|---|---|
| `<app or package>` | `<tool>` | `<tool>` | `<tool>` | `<cmd>` | `<cmd>` |

Cross-app e2e: list the critical journeys in `docs/testing.md`, each as a short ordered list of steps across apps.

---

## Rules (all checkable)

- While working, run the narrowest relevant tests. Before finishing, run the full suite for each app or package you changed, plus consumers of any changed shared package.
- Don't run e2e unless asked, or unless you changed a critical flow (`ASK:` which flows are critical, for example checkout, payment, or sign-up).
- New behavior or a bug fix needs a test. For a bug, write the failing test first.
- Never delete, skip, or loosen a failing test to get green. If the test looks wrong, say so and explain why.
- Unit tests use no network, real time, or randomness.
- Money, inventory, and other correctness-critical logic need **integration tests against a real database**, not mocks. Cases worth covering: concurrent requests competing for the last unit, duplicate or out-of-order webhooks, double-submitted forms. Mocks hide exactly these bugs.
- Don't hide flaky tests with retries. Note them in `docs/progress.md`.
- Name tests after behavior ("rejects checkout when stock is insufficient"). Include the spec ID in the test name, for example `<APP>-<AREA>-<NN> rejects checkout when stock is insufficient` (see `06_specs-and-domain.md`).
- When agents run in parallel, each worktree uses its own port and test database (see `09`).

## Make tests cheap for agents to run

- Give exact commands, including single-file and by-name variants.
- Report only failing tests and the first error, not full logs.
- State prerequisites: how to start the test DB, required env vars, how to launch an emulator or browser, and that only sandbox keys are used.

## Security tests

Write these alongside normal tests (see `10_security-standards.md`):

- **Authorization per route:** unauthenticated, wrong role, and another user's object (user A must not read user B's data).
- **Validation edge cases:** oversize bodies, wrong types, missing and extra fields, out-of-range numbers, malformed IDs.
- **Injection payloads** on search, filter, and sort inputs.
- **Webhooks (if used):** invalid signature rejected, duplicate event processed once, out-of-order event handled, amount mismatch rejected.
- **Business-flow limits:** rate limits and quantity limits on sensitive flows.

## CI

The CI config is the source of truth. `docs/testing.md` only summarizes what runs when (for example unit + integration on every PR, e2e on merge or nightly). Agents open workflow files only when CI fails.

## Accessibility and performance validation

- UI changes run automated accessibility checks where the chosen stack supports them, plus the manual checks that automation cannot prove: keyboard or touch operation, focus order, screen-reader labels, text scaling, contrast, and status that is not conveyed by color alone.
- Performance targets live in `docs/nfr.md` and must name the workload, environment, measurement method, threshold, and review owner. Use representative data and report the relevant percentile or error budget, not only an average local timing.
- Performance-critical changes run the narrowest relevant measurement during development and the agreed measurement before showing or sharing the demo. A missing target is `TODO(decide)`, not an invented threshold.
- The demo walkthrough includes accessibility and performance checks when the project scope or `docs/nfr.md` says they apply.
- For UI demos, test ordinary-page copy separately from information/policy and consequential-action/result states: routine pages must not accumulate repetitive implementation labels, while required limitations must remain visible and truthful where users could infer a real effect. Inspect rendered page text in a real browser, not only source strings.
- Run the relevant smoke and compatibility checks for the intended demo environment; record the build/version, environment, result, and evidence link in the project demo record.
- For each required demo outcome or safety check, identify its verification method (test, inspection, analysis, or demonstration), owner, evidence location, result, and date. A test passing is evidence only for the outcomes it actually verifies.
- Failed, blocked, not-run, and out-of-scope checks are distinct states. An out-of-scope result needs a reason; missing evidence is not a pass.

---

## Templates

**Root `AGENTS.md` section:**

```md
## Testing
- Levels: unit (fast, no network/DB), integration (real DB, fake third parties), e2e (few full journeys). Definitions in docs/testing.md.
- All tests: <app> `<cmd>` | <app> `<cmd>` | <app> `<cmd>`
- While working, run the narrowest relevant tests. Before finishing, run the full suite of each app/package you changed, plus consumers of any changed shared package.
- Run e2e only when asked or when you changed a critical flow (<list>).
- New behavior or bug fix -> add a test (bug fix: failing test first).
- Never delete, skip, or weaken a failing test to pass. If a test looks wrong, say so.
- Money, inventory, and payment logic need integration tests against the real test DB, not mocks.
- Report only failing tests and the first error; don't paste full logs.
- Writing or debugging tests -> read docs/testing.md.
```

**App `AGENTS.md` section:**

```md
## Testing
- All: `<cmd>` | one file: `<cmd> <path>` | by name: `<cmd> <name>`
- Integration (<prerequisites, e.g. emulator, browser, DB>): `<cmd>`
- Layout: <where tests live>. Fakes live in <path>. No real network in unit tests.
- This app uses <shared packages>. Re-run its tests after changes there.
```

**`docs/testing.md` skeleton:**

```md
# Testing
What this covers: test levels, tooling per app, test data, critical e2e journeys, CI mapping.
Read this when: writing, fixing, or debugging tests.

## Levels (our definitions)
## Tooling per app
## Test data and DB reset
## Critical e2e journeys
## CI: what runs when
## Accessibility and performance validation
## Known flaky tests and gaps
```

Add one router row to root `AGENTS.md`: "Writing or fixing tests -> docs/testing.md". If `testing.md` grows past about 80 lines, split into `unit.md`, `integration.md`, `e2e.md` with `testing.md` as the index.

---

## Questions to ask when instantiating

- Which test tools per part?
- How is the test database provided (local container, hosted test instance, in-memory)?
- Which flows count as critical for e2e?
- How are third-party sandboxes (payments, email, and so on) configured for tests?
