# Requirements Discovery and Readiness

**What this covers:** How the agent interviews the demo owner, records demo scope, and decides whether the next demo phase may begin.
**Read this when:** Starting a demo, feature, prototype, visual direction, frontend, or optional backend while requirements are incomplete or ambiguous.
**Last updated:** 2026-11-08

This is a reusable procedure. It does not define the demo's scope, promise production readiness, or approve work on behalf of its owner.

## Core rule

Before preparing a prototype, design, or implementation, inspect the current request and conversation, supplied demo brief, repository, and existing decisions. Reuse known answers; do not ask the user to repeat them. If a decision-critical item for the next phase is missing, ambiguous, or contradictory, pause at that phase's gate and interview the owner before creating its deliverable.

A broad request such as “I want to create a laundry app” is not enough to assume a feature set. First ask what the demo should help its audience understand or try and which laundry service model is meant. Possible models might include a neighborhood laundromat, self-service machines, wash-and-fold pickup, a multi-provider marketplace, or internal staff software—but these are prompts for clarification, not inferred requirements. Do not silently add customer pickup, delivery tracking, driver roles, payment, inventory, seller management, or any other conventional feature.

“Exactly what the user wanted” cannot be guaranteed by questioning alone. Target an owner-confirmed demo outcome and scope, with visible assumptions, exclusions, deferred choices, and success checks the owner can correct.

## Interview protocol

1. **Inspect first.** Review the request, relevant conversation, project files, demo brief, current intake, prototype evidence, and approved decisions. Cite an existing answer instead of asking it again.
2. **Ask one focused topic per turn.** Ask a single concrete question; combine at most three tightly related subquestions only when they form one decision. Explain why it affects the demo's next step. Avoid dumping an exhaustive questionnaire on the user.
3. **Offer balanced options.** When useful, give two or three relevant choices plus “something else,” identify a recommendation and its trade-offs, and let the user decide. A recommendation is not an approval.
4. **Keep unknowns visible.** Record “I don't know” as `TODO(decide)` or ask whether the owner wants to defer it. Do not turn familiar app conventions or popular AI layouts into presumed requirements.
5. **Respect the decision boundary.** The owner may delegate low-risk demo choices; record the delegated boundary and recommendation. Get explicit approval for scope, meaningful cost/timeline trade-offs, sensitive data, security/privacy, payment, contractual commitments, external effects, and actions affecting shared environments.
6. **Maintain the decision/requirements register as answers arrive.** Give each important requirement/decision a stable ID and record its source, status, relevant phase/gate, owner, and approval date. Record changes and conflicts; reopen affected gates when an answer changes the scope.
7. **Read back before advancing.** Summarize the demo outcome, confirmed walkthrough/features, exclusions/deferrals, assumptions, blockers, and the proposed next phase. Ask the owner to confirm or correct it; record the response and date. An acknowledgment only approves the specific items it addresses.
8. **Ask only what the next gate needs.** Do not require production architecture, backend, or operations choices before a fixture-backed prototype if they do not constrain it. Ask deeper production/security/legal/operations questions when the requested demo's data, exposure, integrations, contracts, or deployment makes them relevant.

## Decision statuses

Use `DEM-<number>` (or the product's existing stable requirement ID) for a demo-scope feature/requirement, and `DEC-<number>` for an owner decision. Link each feature to the owner answer/decision that defines it; do not create duplicate IDs when the project already has an ID convention. Use these exact status meanings in the project intake/register:

- `confirmed` — the owner explicitly decided or confirmed the item; cite source and date.
- `recommended—awaiting approval` — the agent suggests an option; it does not authorize proceeding through a blocking gate.
- `TODO(decide)` — unknown, ambiguous, or unresolved; name the owner and say whether it blocks the next phase.
- `deferred` — the owner intentionally postponed the item; record who revisits it and when, and exclude it until then.
- `out of scope` — the owner explicitly excluded the item; record the boundary and reason.
- `not applicable` — the owner confirmed the topic does not apply; record why.

Silence, empty fields, assumptions, generated plans, and an agent-selected design are not `confirmed`.

## Demo discovery areas

This is a coverage map—not a questionnaire to send all at once. Ask the questions relevant to the next gate.

1. **Requested deliverable and audience result:** What does the user want now (scope interview, design exploration, wireframe, clickable prototype, system/architecture design, frontend, backend, or another artifact)? Who will view/use the demo? What should they understand, decide, or try? What observable result makes it successful? Do not change phases or create a larger artifact without approval.
2. **Service model and roles:** What kind of product/service is being demonstrated? Who uses or operates it? What does each role need to accomplish? Which actors/roles are explicitly not part of this demo?
3. **Primary walkthrough:** What is the one most important story from a clean starting state to an observable result? Which screens/actions are required? What should be left for a later demo?
4. **Behavior and boundaries:** What business rules, options, status changes, edge/error/empty/recovery states, permissions, or human approvals matter to the walkthrough? What should the demo explicitly not do?
5. **UI and content:** Which platform/device/context? What language, accessibility needs, product/content facts, navigation, brand/design references, or visual direction matter? How should the owner review the prototype?
6. **Simulation and safety:** Which data/services are fixtures, mocks, or stubs? What must look interactive? What should the presenter disclose before and after consequential actions? How does reset/recovery work, and what environment/data must never be affected?
7. **Technical choices when relevant:** What existing stack, environment, integration, auth, performance, accessibility, or delivery constraint actually blocks the requested phase? Is frontend-only enough, or is a sandbox backend necessary to prove the named walkthrough?

Do not require live payment, a production integration, a full backend, or production-only infrastructure unless the owner says it is necessary for the demo outcome. Identify conditional security/privacy/compliance/operations needs when real data, external effects, contractual commitments, or wider exposure change the risk.

## Feature completeness for the demo scope

For each in-scope feature needed by the next phase, capture:

- Stable ID and the owner answer/brief item it came from.
- Audience role, task/problem, and trigger.
- Expected visible behavior/result in the demo.
- Priority: `MVP walkthrough`, `optional polish`, `later`, or `out of scope`.
- Required inputs/content and relevant business/state rules.
- Important alternate, validation, error, empty, permission, recovery/reset, and disclosure behavior.
- Whether the behavior is real within the demo, fixture-backed, mocked, or intentionally absent.
- Acceptance check/walkthrough evidence, owner, status, and date.

Do not build a feature simply because it is common in laundry apps or e-commerce systems. Record anything deliberately absent as out of scope, deferred, or not applicable with an owner-confirmed reason.

## Phase gates

A phase may proceed when its required items are confirmed or explicitly delegated within a recorded low-risk boundary. A blocking `TODO(decide)`, pending recommendation, or unresolved conflict means pause and ask. A nonblocking unresolved item may proceed only if the owner explicitly defers it and the item is excluded from the phase scope.

### Gate A — demo intent before prototype planning

Confirm the audience, demonstrated outcome, primary walkthrough, success signal, relevant roles/service model, initial MVP scope, later/optional scope, explicit exclusions, known demo constraints, and decision owner. Read these back and get owner confirmation before planning the prototype. The concept alone is not permission to invent the walkthrough.

### Gate B — experience before making a prototype

When a UI or interactive prototype is in scope, confirm role-specific tasks, device/platform context, route/screen inventory, main and important alternate/error states, content facts, navigation expectations, visual thesis or references, prototype fidelity, simulation boundaries, disclosures, reset/recovery, and how the owner will judge the result. Resolve decision-critical design and role/navigation questions before creating screens. Follow `02_design-md.md` for design exploration; optional external design references do not replace product discovery or owner choice.

For a non-UI demo, confirm its hypothesis, interfaces, starting conditions, simulated behavior, evidence, and success/failure criteria instead. Mark UI `not applicable` only with an owner-confirmed reason.

### Gate C — system/architecture design (only when needed)

System or architecture design is not automatically required for a fixture-backed prototype. Before creating an architecture/system design, confirm what question it must answer and which owner-approved walkthrough/features it supports. Ask about only relevant platform/stack constraints, data and state, integrations/contracts, identity/access, environment, security/privacy, measurable quality needs, and technical acceptance/evidence. Record the considered options, recommendation/trade-offs, decisions, and explicit exclusions; obtain owner confirmation before treating the design as a build plan. Do not design services, databases, or infrastructure merely because they are conventional for the product category.

### Gate D — frontend implementation

Before building the demo frontend, confirm the approved prototype/evidence, included routes and features, content and role behavior, fixture/mock contracts, environment, reset/recovery safety, truth-in-demo disclosures, responsive/accessibility expectations, and acceptance checks. Choose only the stack/tools necessary for the agreed demo. Do not start implementation that depends on an unresolved decision.

### Gate E — optional backend or external integration

A backend/integration is not an automatic phase requirement. Before starting one, confirm what specific walkthrough requirement cannot be validated with local fixtures, the data/service contract, sandbox and credentials owner, authentication/authorization, privacy/security, external side effects, failure/reset behavior, test evidence, and human approval boundaries. If no owner-confirmed need exists, retain the documented fixture-backed demo and leave backend work out of scope.

A demo phase gate is not production readiness, security certification, legal approval, client acceptance, or release approval. Use the other project records for any such requirement.

## Register and read-back formats

Copy/adapt this table in the project-root `PROJECT_INTAKE.md` or a linked project decision register. Keep project facts outside the copied blueprint.

| ID | Topic / requirement or decision | Source | Status | Gate / blocks next phase? | Owner | Approval / date | Notes or reason |
|---|---|---|---|---|---|---|---|
| `<DEM-001 or DEC-001>` | `<demo feature or owner decision>` | `<user / brief / path>` | `<confirmed / recommended—awaiting approval / TODO(decide) / deferred / out of scope / not applicable>` | `<A/B/C/D/E; yes/no>` | `<role>` | `<approval/date or pending>` | `<visible success / reason / revisit point>` |

Before advancing, read back:

```text
Audience and demo outcome: <who; what should they understand/do>
Confirmed primary walkthrough: <start -> actions -> visible success>
MVP walkthrough scope: <features/screens included>
Optional/later: <deferred and excluded until revisited, or none>
Out of scope / not applicable: <owner-confirmed boundaries and reasons, or none>
Simulation, disclosure, and reset: <what is mocked; what the viewer sees; safe recovery>
Assumptions: <explicit items for owner correction>
Blocking unknowns or conflicts for this phase: <items; none means none were found for this phase>
Proposed next phase: <phase and bounded artifact>
Please confirm or correct this demo scope before I proceed.
```

Record the owner's explicit response, identity/role, date, scope version, and affected decision IDs. Update and reread the affected items if the owner corrects the summary.

## Stop conditions

Pause and ask the owner when:

- The audience, outcome, service model, primary walkthrough, or required feature is unclear for the next phase.
- Roles, navigation, states, or success criteria conflict or are missing for a requested UI prototype.
- A fixture/mock boundary, reset safety, or disclosure could mislead a viewer or affect real/shared data.
- A requested phase depends on an unapproved technical, cost/timeline, privacy/security/payment, legal, integration, or external-effect decision.
- The owner has not approved a material assumption or scope read-back.

Proceed with only the bounded phase the owner confirmed. Do not claim the demo scope is exhaustive when optional/later discovery remains, and do not call a fixture-backed demo production-ready.
