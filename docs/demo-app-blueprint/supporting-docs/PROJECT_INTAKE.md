# Demo Project Intake

**Purpose:** Record the decisions needed to make one demo reproducible, safe, and easy to present. Copy this file to the project root as `PROJECT_INTAKE.md`; do not edit the blueprint copy.

**Instructions:** Start with the copied blueprint folder's `PROJECT_SETUP.md`; inspect the request, conversation, brief, repository, and existing decisions before asking questions. Use the copied guide at `demo-app-blueprint/supporting-docs/requirements-discovery-and-readiness.md` to interview the demo owner one focused topic at a time. Complete this project-root worksheet with the demo owner and technical owner. Mark every unanswered decision-critical field `TODO(decide)`, name its owner and whether it blocks the next phase, and never treat blanks as confirmation. Record recommendations separately from approved decisions.

## 1. Demo goal and audience

- Demo name: `<name>`
- Audience and roles: `<who will watch or use it>`
- Problem or capability demonstrated: `<outcome>`
- Presentation date/window: `<date or unknown>`
- Success signal: `<what the audience should understand or do>`

## 2. Scope and deliverables

- Deliverable shape: `<web/mobile/desktop/API/service/CLI/other>`
- In-scope walkthrough outcomes: `<list>`
- Explicitly out of scope: `<list>`
- Known limitations or simulated behavior: `<list>`
- UI design direction: `<brief-derived visual thesis; role-specific navigation; product-specific imagery/content; representative screens or design references; review status/owner>`
- External design reference/MCP policy: `<none / DesignMD or other; approved source and exposed tool(s); owner approval; public-Markdown fallback; TODO(decide)>`
- User-facing copy/disclosure approach: `<ordinary UI language; information/policy page; relevant action and confirmation/status disclosures; TODO(decide) if unresolved>`
- Default project sequence: `<Prototype -> Frontend -> Backend; backend optional only if documented and approved>`
- Phase owners and exit criteria: `<prototype owner/gate; frontend owner/gate; backend owner/gate or N/A>`
- Prototype record: `<source/decision IDs, owner-confirmed Gate A/B read-back and date, audience/success signal, primary walkthrough, confirmed MVP/out-of-scope, multipage route/screen inventory/navigation, fixture/mock boundaries, disclosures/reset states, prototype link/evidence, walkthrough checks, validation participants/results>`
- Repository and runtime: `<decision or unknown>`

## 3. Environment and data

- Setup and launch method: `<commands or steps>`
- Demo environment and owner: `<local/sandbox/hosted/other>`
- Data source: `<synthetic/approved fixture/sandbox service/other>`
- Seed method: `<command or procedure>`
- Reset method and safety check: `<command or procedure>`
- Demo accounts and roles: `<list; no passwords>`
- Secrets/configuration owner: `<role and approved store>`

## 4. Quality and safety

- Build, lint, static checks, and focused tests: `<commands>`
- Complete walkthrough smoke test: `<steps/evidence>`
- Authentication and authorization behavior: `<decision>`
- Sensitive data or external side effects: `<none or describe>`
- What is mocked, disabled, delayed, or incomplete: `<list>`
- Human approval needed before showing or sharing: `<list>`

## 5. Agent operations

- Operating model: `<single agent / PM + sequential workers / PM + parallel workers / scheduled automation / hybrid>`
- PM/coordinator profile and human owner: `<decision or TODO(decide)>`
- Orchestration layer: `<Orca / Hermes-native / another ADE / manual / N/A>`
- Worker roles and allowed agents/models: `<SE / QA / research / reviewer / other>`
- Worker session/worktree policy: `<isolated worktree / current workspace / other>`
- Task/completion/evidence contract: `<decision or link>`
- Approved skills and permissions: `<list>`
- Loop/harness scope and human gates: `<decision>`
- Iteration/time/tool/cost/worker/depth/retry budgets: `<limits>`
- Automation policy: `<supervised only / goal-driven / scheduled / unattended with approval>`
- Automation contract: `<trigger/input/scope/validation/idempotency/retry/observability/reset-disable decision or link>`
- Provider request limit: `<provider/model alias/endpoint; verified input or total limit; whether output counts; evidence source/date>`
- Automatic compaction: `<enabled; configured model/context window; ratio and/or absolute token trigger; output reservation/headroom check>`
- Task checkpoint/handoff: `<threshold separate from compaction; approved location, retention, cleanup, and resume procedure>`
- Parallel worker isolation, shared resources, integration, and merge rule: `<decision or N/A>`
- Evaluation/red-team scenarios required: `<list>`
- Human approval boundaries: `<destructive actions / external effects / data / sharing / other>`

Use the copied blueprint folder's `PROJECT_SETUP.md` for the default operating model, `supporting-docs/22_multi-agent-coordination.md` for the generic worker contract, and `supporting-docs/09_tool-profiles.md` for tool-specific behavior. Record the selected workflow, not just the recommendation.

## Requirements discovery and phase readiness

Follow `demo-app-blueprint/supporting-docs/requirements-discovery-and-readiness.md` for the interview and phase gates. Interview the owner about missing user needs; do not infer features from the product category. Record source/decision IDs, scope status, gate blockers, and owner read-back. Unknown or unapproved blocking items mean stop at that gate.

- Audience and intended demo outcome: `<confirmed / TODO(decide); source ID>`
- Service model and roles: `<confirmed / TODO(decide); source ID>`
- Primary walkthrough and observable success: `<confirmed / TODO(decide); source ID>`
- Confirmed MVP walkthrough features/screens: `<IDs / list>`
- Optional/later, owner and revisit point: `<IDs / list or none>`
- Explicit out-of-scope features/boundaries, reason, and owner: `<IDs / list or none>`
- Blocking unknowns/conflicts for the next gate: `<IDs / owner / TODO(decide) or none>`
- Current gate and bounded next phase: `<Gate A/B/C/D/E; artifact>`
- Fixture/mock boundary and simulated behavior: `<decision IDs / summary / TODO(decide)>`
- Truthful disclosures, safe environment, reset/recovery: `<decision IDs / summary / TODO(decide)>`
- Scope read-back: `<pending/confirmed/corrected>`; owner: `<role>`; version/date: `<value>`

| ID | Requirement/decision and priority | Source/version | Status | Gate / blocks next phase? | Owner | Approval/date | Demo success check, reason, or revisit point |
|---|---|---|---|---|---|---|---|
| `DEM-001` | `<audience need/walkthrough feature; MVP/later/out of scope>` | `<user answer / brief / section>` | `<confirmed / recommended—awaiting approval / TODO(decide) / deferred / out of scope / not applicable>` | `<A/B/C/D/E; yes/no>` | `<role>` | `<approval/date or pending>` | `<visible result / evidence / reason / revisit point>` |

Before each gate, read back confirmed audience/outcome/scope, accepted recommendations, assumptions, deferred/excluded/N/A items and reasons, blockers, disclosures/reset boundaries, and the proposed bounded next phase. Record the owner's explicit response below; update and re-confirm if corrected.

- Owner read-back response: `<quote/link or pending>`
- Confirmed by / role / date: `<value or pending>`
- Scope/decision register version: `<value>`

## Decision register

| ID | Decision | Recommendation/options | Final decision | Owner | Date/approval |
|---|---|---|---|---|---|
| `<DEC-001>` | `<question>` | `<options>` | `<decision or TODO(decide)>` | `<role>` | `<date>` |

Use the decision statuses in the discovery guide. Keep demo readiness distinct from production readiness.
## Show-ready checklist

- [ ] Goal, audience, scope, and limitations are documented.
- [ ] Setup, launch, seed, and reset are reproducible.
- [ ] Data is synthetic or explicitly approved; no secrets are committed.
- [ ] Primary walkthrough succeeds from a clean/reset state.
- [ ] Limitations are disclosed in plain language at relevant information, action, and confirmation/status points; full implementation details remain in presenter/project notes.
- [ ] Routine UI copy is product-focused without repetitive implementation labels; limitations are clear at relevant information, action, and result points, and no fixture-backed status is represented as live.
- [ ] Applicable checks pass and failed/skipped checks are recorded.
- [ ] Human owner and recovery path are known.
- [ ] The copied blueprint folder remains unchanged.