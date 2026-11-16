# Demo Walkthrough and Reset

**What this covers:** How to make the demo's key story reproducible, easy to present, and safely reset between runs.
**Read this when:** Choosing demo scenarios, preparing a presentation, documenting a scripted walkthrough, or implementing seed/reset behavior.
**Last updated:** 2026-11-02

## Demo story

Keep a short walkthrough tied to the audience's goal. A scenario names its starting state, actor/role, actions, expected visible result, recovery/reset step, and known limitation.

| ID | Audience goal | Starting state | Steps | Expected result | Reset/recovery | Status/evidence |
|---|---|---|---|---|---|---|
| `<DEMO-01>` | `<goal>` | `<state>` | `<steps>` | `<observable result>` | `<safe reset>` | `<passed/failed; link>` |

## Presentation preparation

Before a demo:

1. Verify the target environment, version, feature flags, connectivity, and presenter permissions.
2. Reset to the documented baseline using a reversible, environment-scoped procedure.
3. Run the main walkthrough end-to-end and confirm the visible result matches the expected story.
4. Check seeded records, demo accounts/roles, and any mocked or simulated integrations.
5. Audit ordinary pages for repetitive implementation labels and check that user-facing limitations appear before consequential actions and in their result/status views.
6. Capture the current limitation/contingency notes for the presenter.

Never use an unverified cleanup or reset action during a live session. If reset fails, stop and use the documented recovery path rather than manually modifying shared or production data.

## Reset contract

A reset procedure documents its target environment, exact scope, authorization, preconditions, command/action, expected postcondition, verification query/check, idempotency, failure behavior, owner, and last test date. Destructive reset actions require a sandbox/local target, explicit environment guard, and human approval where applicable. Refuse if the target cannot be positively identified as disposable.

For UI demos, the walkthrough record also notes which routine pages were checked for natural product language and which consequential action/result states were checked for concise, truthful disclosures. Verify the visible result matches the actual side effect: a local preview must not be described as a completed real payment, message, account action, inventory update, or shipment.

## After the demo

Record unexpected behavior, audience questions, reproducibility issues, and follow-up decisions in project-owned progress/issues. A successful presentation is not external approval or evidence of production readiness.

## Questions to resolve

- Which two or three user-visible outcomes best tell the demo story?
- What exact clean starting state does each scenario require?
- Who owns the walkthrough and reset procedure?
- How is reset tested and restricted to the disposable demo environment?
- Which limitations or simulated behaviors must presenters disclose?
