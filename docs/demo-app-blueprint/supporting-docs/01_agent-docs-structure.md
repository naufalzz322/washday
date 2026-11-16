# Agent Docs Structure

**What this covers:** How to organize `AGENTS.md` files, skills, `docs/`, the progress tracker, and the changelog so agents read only what a task needs.
**Read this when:** Creating or changing `AGENTS.md`, `.agents/`, `docs/`, the progress tracker, or the changelog.
**Last updated:** 2026-11-02

This file is a **template**. It contains no stack choices. Anything marked `ASK:` is a question for the project's writer; collect decisions in the project-root `PROJECT_INTAKE.md` and follow `../PROJECT_SETUP.md`.

---

## Principles

1. **Progressive disclosure.** Always-loaded files are small and act as an index. Detail lives in other files opened only when relevant.
2. **Router, not manual.** Root `AGENTS.md` says where to look, not everything.
3. **One topic per file**, about 80 lines max, each starting with "What this covers / Read this when".
4. **Document what can't be inferred from code:** commands, conventions, gotchas, "never do X because Y". Don't describe code the agent can read.
5. **No duplicated rules** between root and app files. Copies drift and contradict.
6. **Never** write "read all docs before starting". It is the most common cause of agents reading too much.

---

## Project shapes

- **Monorepo with several deliverables** (for example mobile, web, API, desktop, CLI, worker, or data/automation parts): use the layout below and create one app/package instruction file per owned part.
- **Single deliverable:** one `AGENTS.md`, specs in `docs/specs/<feature>.md`, no `apps/` folder, and `packages/` only if code is shared.
- **Non-UI deliverable:** omit `DESIGN.md`; use protocol, output, schema, scheduling, idempotency, observability, and operator documentation instead.
- **Desktop or CLI:** record supported operating systems/runtimes, installation/distribution, upgrade/uninstall behavior, local data and permissions, offline behavior, and signing where applicable.
- **Service, worker, or data/automation:** record triggers/schedules, input/output contracts, retries and idempotency, replay/backfill behavior, data quality and reconciliation, resource limits, failure handling, and operator runbooks.
- Add or drop folders to fit the project. The rules (router, size limits, headers) stay the same.

---

## Repository layout

```
/
├── README.md              # for humans: what it is, setup, run (each app has one too)
├── PROJECT_INTAKE.md      # copied and completed when adopting this blueprint
├── AGENTS.md              # router + shared conventions (short)
├── DESIGN.md              # shared design rules (only if the project has a UI)
├── CHANGELOG.md           # generated, root only, never hand-edited
├── <tool config files>    # permissions, worktree setup, etc. (see 09)
├── scripts/check-docs     # CI doc check (see 07)
├── <PR template>          # mirrors the definition of done (see 07)
├── .agents/
│   └── skills/<name>/SKILL.md
├── apps/
│   └── <app>/             # AGENTS.md, DESIGN.md (UI apps, differences only), docs/specs/
├── packages/              # only for code shared by two or more apps (see 03)
│   └── <package>/         # AGENTS.md
└── docs/
    ├── architecture.md
    ├── api-contract.md    # API conventions only; endpoints come from the generated spec (see 05)
    ├── realtime.md        # only if the project uses realtime channels
    ├── domain.md          # glossary, roles, state machines (see 06)
    ├── security.md        # index; topic files live in docs/security/ (see 10)
    ├── security/          # input-validation, auth-and-access, payments (if applicable), supply-chain-and-secrets, privacy, platform-hardening, agents
    ├── nfr.md             # performance and other budgets (see 07)
    ├── operations.md      # environments, observability, readiness, rollback (see 11)
    ├── demo-walkthrough-and-reset.md # scenarios, baseline, seed/reset, recovery
    ├── demo-data-and-safety.md # demo data, secrets, sandbox, disclosure
    ├── agent-skills.md    # skill lifecycle and governance (see 20)
    ├── agent-loop-and-harness.md # bounded autonomous loop (see 21)
    ├── multi-agent-coordination.md # delegation and integration (see 22)
    ├── agent-evaluation-and-red-teaming.md # capability evaluation (see 23)

    ├── reference/         # requirements document (SRS, PRD, brief) and other source docs, read only when asked
    ├── testing.md
    ├── runbooks/          # deploy, rollback, backup-restore, incident
    ├── demo/              # walkthrough notes, screenshots, recordings, or fixtures if needed
    ├── <topic>.md         # one file per major subsystem, e.g. auth, database, billing (as needed)
    ├── progress.md
    ├── progress-archive.md
    └── decisions/         # short dated ADRs
```

Folder and package naming follows the conventions of the project's stack.

---

## Root `AGENTS.md` (target: about 100-150 lines)

**Contains:**

- Project overview and repo map
- How the apps relate to each other
- Commands to install, run, build, and test each part, listed side by side when the project mixes ecosystems
- Conventions that apply everywhere
- A "read when" router table
- Short Code style, Testing, and Security sections (full skeleton: `08_agents-md-skeletons.md`)

**Router table example:**

```md
## Where to find things (read only what the task needs)

| If you're working on...        | Read                           |
|--------------------------------|--------------------------------|
| Anything touching the API      | docs/api-contract.md           |
| A major subsystem (<topic>)    | docs/<topic>.md                |
| Writing or fixing tests        | docs/testing.md                |
| Deploy, rollback, restore      | docs/runbooks/                 |
| Writing or updating the demo walkthrough | docs/demo-walkthrough-and-reset.md |
| Domain terms, state machines   | docs/domain.md                 |
| Security (auth, validation, payments, privacy, secrets) | docs/security.md (index) |
| Performance-critical code      | docs/nfr.md                    |
| Operations, observability, and readiness | docs/operations.md       |
| Demo data, credentials, integrations, or sharing | docs/demo-data-and-safety.md |
| Demo reset, seed, recovery, or known limitation | docs/demo-walkthrough-and-reset.md |
| Building a feature (per app)   | apps/<app>/docs/specs/<feature>.md |
| Building or changing UI        | DESIGN.md (and the app's own)  |
| Picking up or planning work    | docs/progress.md (top section) |
| Why a past decision was made   | docs/decisions/                |
```

**Required lines in the root file:**

- Do not read `docs/` files unrelated to the current task.
- Do not read any `CHANGELOG.md` or `progress-archive.md` unless asked.
- Before working in an app, list its directory so its `AGENTS.md` loads (see `09_tool-profiles.md`; some tools load nested files lazily).
- Never hand-edit generated files (the exported API description, generated API clients, generated token outputs). Regenerate with `<command>`.
- Commit convention: Conventional Commits with an app scope, e.g. `feat(<app>): ...`, `fix(<app>): ...`.
- Progress rule (see Progress tracker below).
- Testing policy (see `04_testing.md`).
- Documentation rules: generated endpoint docs, one owning doc per fact, walkthrough results and limitations are recorded by humans (see `05_documentation-and-demo-walkthroughs.md`).
- **Boundaries** block, **Definition of done** block, and the **precedence rule** (see `07_guardrails-and-maintenance.md`).
- Demo readiness: a reproducible setup, primary walkthrough, safe data/reset path, disclosed limitations, and applicable check evidence.
- Specs: one app per spec file; IDs like `<APP>-<AREA>-<NN>` (see `06_specs-and-domain.md`).

---

## App and package `AGENTS.md`

App-specific content only, kept **short (target 80 lines or fewer)**:

- Stack and a one-line **Decisions** block for framework-level choices the agent can't infer from code (for example state management, routing, folder structure, error handling). `ASK:` the writer for each, or recommend one.
- App-specific commands (run, test, codegen)
- A canonical example path to copy (a reference feature)
- A small router to app-level docs, read only when needed
- Gotchas

**Keeping it short:** record the *choice* and any project-specific rule, not an explanation of the library (the agent already knows common libraries). Put anything longer in `apps/<app>/docs/` and point to it from a router row such as "Adding a feature -> docs/architecture.md". Procedures like "add a feature" belong in a skill.

A full app skeleton (Decisions, Commands, Code style, Testing, Gotchas, Read when) is in `08_agents-md-skeletons.md`.

Example Decisions block (placeholders until the choices are made):

```md
## Decisions
- <Decision 1, e.g. state management>: <choice>. <One project-specific rule.>
- <Decision 2, e.g. routing>: <choice>. Defined in <path>.
- Structure: <layout>. Reference feature: <path>.

## Read when
| Adding a feature or screen     | docs/architecture.md |
| Building or changing a feature | docs/specs/<feature>.md |
| Writing tests                  | docs/testing.md (root) |
```

An API app's `AGENTS.md` should also cover (one line each, details in an app doc): how to run locally and deploy, the available environments, the data-migration workflow (generate, review, apply), how it connects to its database, and the rule that every route is defined with its schema so the API description stays complete.

Packages get a short file too: "Changes here affect every app. Run tests for each consuming app after any change. Don't add app-specific code here."

---

## Tool-specific behavior

This file is tool-agnostic. Tool-specific facts (how each tool loads instruction files, where it reads skills, how permissions work) live in `09_tool-profiles.md`. What this plan assumes of any tool:

- **Nested `AGENTS.md` files** may load eagerly or lazily. Keep the root rule "before working in an app, list its directory so its `AGENTS.md` loads" until the loading check in `09` shows the tool loads them eagerly.
- **Skills** live in `.agents/skills/<name>/SKILL.md` at the repo root, the tool-neutral location. Whether a tool reads it natively is recorded in `09`; if not, symlink or sync. Lifecycle, scope, approval, testing, and deprecation are owned by `docs/agent-skills.md`.
- **Agent loops and harnesses** must be bounded, resumable, observable, and human-gated where required. The project contract is in `docs/agent-loop-and-harness.md`; implementation syntax is in `09`.
- **Parallel agents** require task contracts, one owner, isolated workspaces/resources, dependency and lock rules, and merge verification. The project contract is in `docs/multi-agent-coordination.md`; orchestrator syntax is in `09`.
- **Evaluation** covers happy paths and negative/red-team cases before trusting a skill, harness, model/tool version, or orchestration change. The project contract is in `docs/agent-evaluation-and-red-teaming.md`.
- **Permissions and approvals** are configured per tool, sometimes at user level outside the repo. Enforcement rules are in `07`, syntax in `09`.
- **Context file size** may be capped by the tool. Keep each file well under the cap (root about 150 lines, others about 80).
- **One loaded instruction type:** some tools load only one instruction file type, first match wins. Use `AGENTS.md` only, and don't add tool-specific override files next to it.

---

## `.agents/skills/`

Skills hold **procedures**; `AGENTS.md` holds **facts and conventions**. Good skill candidates:

- Add an API endpoint
- Add a screen or page to an app
- Write a data migration
- Create a shared component
- Add a unit test / integration test / e2e flow
- Write a spec; write or update a demo walkthrough

---

## `docs/`

- One topic per file, about 80 lines max.
- Each file starts with a two-line header: "What this covers / Read this when".
- Referenced from the router table, never from an "always read" list.
- If a file grows past about 80 lines, split it and keep the original as an index.

---

## Progress tracker (`docs/progress.md`)

- A short **Current** section on top: in-progress items plus the next 3-5.
- One line per item with a **stable ID** (reduces merge conflicts).
- Finished items move periodically to `progress-archive.md`, which is never read unless asked.
- `AGENTS.md` tells agents to read only the top section.

**Rule to put in root `AGENTS.md`:**

```md
After finishing work that matches an item in the "Current" section of docs/progress.md,
update that item's status in one line. Don't add entries for refactors, typo fixes, or
small tweaks. If unsure whether the work is tracked, don't edit the file.
```

---

## Changelog

- Single `CHANGELOG.md` at the repo root, **generated** from Conventional Commits.
- Commit scopes per app (`feat(<app>): ...`) so the generator groups entries by app.
- Agents never edit it by hand and never read it unless asked.
- `ASK:` which generator to use, or recommend one that builds from commit history without taking over the release workflow, unless the project already automates releases.

---

## Decisions (`docs/decisions/`)

Short, dated entries (one decision each, file name `YYYY-MM-DD-<slug>.md`) so past choices aren't re-litigated.

---

## Stack decisions

The stack is an input. These files contain no stack choices; ask the writer and record decisions in the project-root `PROJECT_INTAKE.md`.

- **Where the stack comes from, in order:** (1) the writer's own decisions, (2) what the requirements state or imply, (3) a recommendation when neither settles it.
- **Never assume silently.** If a part of the stack is unknown, ask, or propose 2 to 3 options with a recommendation, reasons, and trade-offs.
- **Advise when the requirements point to something better** than the writer's choice. Signals include scale and concurrency, realtime, offline use, compliance or data residency, budget, team skills, timeline, and existing systems or integrations. Each piece of advice names the requirement it responds to, the alternative, the trade-offs, and the cost of switching. The writer decides; advice never overrides a decision.
- **Record every stack decision** as a short dated entry in `docs/decisions/`, and reflect it in the root repo map and the app's `AGENTS.md`. Revisit only when the requirements change.

---

## Anti-patterns

- A `CONTEXT.md` that restates `AGENTS.md` and the code (duplicate that goes stale)
- "Read all docs before starting"
- Descriptions of code the agent can read directly
- Trackers or changelogs inside always-loaded files
- Hex values or contract details copied into markdown when the code is the source of truth
