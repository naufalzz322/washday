# Specs and Domain Docs

**What this covers:** Per-app feature specs with IDs, links to demo checks and tests, the domain glossary and state machines, and where the source requirements document lives.
**Read this when:** Writing or reading a feature spec, defining success criteria, or looking up domain terms and lifecycles.
**Last updated:** 2026-11-02

This file is a **template**. It contains no project facts or stack choices. `ASK:` marks questions for the project's writer.

---

## Why a spec layer

Nothing else in the plan says what to build in detail. `docs/progress.md` lists items, and the source requirements document (an SRS, PRD, scope doc, brief, or demo brief) usually has no per-app requirement IDs. Specs give agents short, current, per-app requirements, and give demo scenarios and automated tests something to reference.

---

## Rule: one app per spec file

**A spec file covers exactly one app (or one package). Never put two or more apps in the same spec file.**

A feature that spans apps (for example a checkout flow touching a customer app, the API, and an admin app) gets one spec file per app, linked by ID. Product-level flows that cross apps live in `docs/domain.md` as state machines, not as specs. In a single-app project the rule is trivially satisfied.

---

## Layout

Specs are co-located with the app they describe:

```
apps/
  <app>/docs/specs/<feature>.md
packages/<pkg>/docs/specs/<feature>.md   # only if a package has behavior worth specifying
docs/
  domain.md                              # glossary, roles, state machines, shared rules
  reference/<requirements-doc>.md        # SRS, PRD, brief, or scope doc; read only when asked
```

Why co-locate: reading a spec inside an app also loads that app's `AGENTS.md` in tools that load nested files on demand, context stays per app, and ownership is clear. Each app's `AGENTS.md` has a router row: "Building or changing a feature -> docs/specs/<feature>.md".

One feature per file, about 80 lines max, each with the "What this covers / Read this when" header.

---

## IDs

- Format: `<APP>-<AREA>-<NN>`, where `<APP>` is a short uppercase code per app (`ASK:` or propose codes, for example `WEB`, `API`, `MOB`) and `<AREA>` is a short feature-area code. Examples: `WEB-AUTH-01`, `API-ORD-03`.
- Stable and never reused. A deprecated requirement is marked deprecated, not deleted.
- Every requirement and success criterion carries its ID.
- All IDs inside a spec file use that app's prefix.

## Cross-app linking

- Specs refer to other apps **by ID only**: "Depends on: API-ORD-03".
- API request and response shapes live in the API's schemas and the generated API description. Client specs reference them, never copy them.
- Lifecycles, roles, and shared rules live in `docs/domain.md`.

## Lightweight evidence chain

```
source requirement -> spec or explicit disposition -> success criterion
  -> verification method and evidence -> demo walkthrough or other agreed check
  -> automated test name where automation applies -> recorded demo outcome
```

For a demo, map in-scope brief items to a spec or explicitly record out-of-scope, duplicate, ambiguous, deferred, or not-applicable items with a reason. Each requirement and success criterion records its verification method, evidence location, owner, status, and date. Missing evidence is not a pass. A test name includes the spec ID where automation applies; walkthrough outcomes are recorded by a human.

Example test name: `WEB-AUTH-01 rejects login after too many failed attempts`. Items in `docs/progress.md` reference spec IDs.

---

## Spec template

```md
# <Feature> (<app>)
What this covers: <one line>
Read this when: <one line>
Status: draft | agreed | built | deprecated
Depends on: <IDs from other apps or packages, if any>

## Goal
## Requirements
- <APP>-<AREA>-01 <requirement>
  - Verification method: <test | inspection | analysis | demonstration | other>
  - Evidence: <path or retained artifact>
  - Owner: <role> | Status: <unverified | passed | failed | blocked | N/A> | Date: <date>
## Success criteria
- <APP>-<AREA>-01: given <state>, when <action>, then <result>
  - Verification method: <method> | Evidence: <path or artifact> | Owner: <role> | Status: <status> | Date: <date>
## Edge cases
- <case and expected behavior; include verification/evidence when applicable>
## Abuse cases (only for specs touching money, personal data, or auth)
## Out of scope
## Open questions
```

## Discovery and confirmation before spec agreement

Before converting a broad demo idea into features, follow `requirements-discovery-and-readiness.md`. Ask the owner when a walkthrough feature, actor, priority, service model, rule, state, simulation boundary, exclusion, or success check is missing or contradictory; do not fill gaps with features common to the product category. Link each in-scope demo requirement and success criterion to a stable intake/decision ID and its source.

A spec may be drafted while answers are pending, but it remains `draft` and records open questions and phase blockers. Do not create a prototype or implement affected behavior until the applicable gate and owner read-back are confirmed. `Agreed` means the owner approved this specific in-scope version; a recommendation, generated document, or general acknowledgement is insufficient. Reopen the gate when an answer changes the walkthrough or boundaries.

## Agent rules

- A spec is `agreed` only when the human owner explicitly confirms its recorded version. Implement only confirmed in-scope behavior; ask about missing or conflicting decision-critical details.
- Agents may draft specs from owner answers, link stable source IDs, and update statuses; they cannot self-approve or infer a feature list.
- When behavior changes, update the spec and flag affected owner decisions/gates for confirmation.
- Never combine two apps in one spec file. If a feature needs another app's behavior, add a `Depends on` ID.
- Preserve `demo brief/owner answer -> scope or explicit exclusion -> success criterion -> check/walkthrough evidence -> recorded demo outcome`. A fixture-backed success is not evidence of a live external effect.
- Do not treat an agreed feature spec as approval of unspecified design, architecture, production readiness, data use, or external effects.

---

## Source requirements document handling

- Keep the source requirements document(s) (SRS, PRD, scope doc, brief) and any review notes in `docs/reference/`. First line of each: "Source document. Specs and decisions override it."
- Read them only when asked, or when writing a new spec.
- Convert the requirements into specs one feature at a time, when the feature is about to be built, not all up front.

---

## `docs/domain.md`

One topic file, about 80 lines max (split into `docs/domain/<area>.md` files if it grows):

- **Glossary:** one line per term.
- **Roles:** each user role and what it can do.
- **Lifecycles** of the main entities, as state machines. If the requirements use local-language labels, keep those as user-facing labels and map them to the identifiers used in code, in a small table.
- **Business rules** the code must respect, for example inventory reservation, pricing, refunds, or eligibility rules.
- **Payment states (if the project takes payments):** the states and which transitions are allowed (enforced on the server only).
- **Shared constants:** currency, timezone, locale.

**Naming rule:** `ASK:` the language for code, database, and API names (commonly English). User-facing text lives in localization files and is never hardcoded.
