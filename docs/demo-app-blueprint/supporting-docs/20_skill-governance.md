# Agent Skill Governance

**What this covers:** How project skills are designed, cataloged, reviewed, tested, versioned, approved, composed, deprecated, and safely executed.
**Read this when:** Creating, changing, installing, evaluating, or removing an agent skill.
**Last updated:** 2026-11-02

This file is a tool-agnostic blueprint. Instantiate it as `docs/agent-skills.md`; tool-specific discovery, precedence, permissions, and write-approval behavior belongs in `09_tool-profiles.md`.

## Skill contract

Every `.agents/skills/<name>/SKILL.md` has one precise procedure and a catalog entry with:

- Name, version, owner, status (`draft`, `approved`, `deprecated`), and last review date.
- Trigger: when to use it and when not to use it; do not load every skill for every task.
- Inputs and preconditions: required files, decisions, credentials, environment, and approvals.
- Allowed scope: paths, tools, commands, network access, side effects, and data classifications.
- Ordered procedure with checkpoints, expected outputs, verification, stop conditions, and escalation path.
- Failure handling, idempotency or resume behavior, dependencies on other skills, and compatibility assumptions.
- Evidence produced and where it is retained; never claim an external side effect without a verifiable handle.

A skill contains a procedure, not a second project policy. Shared facts belong in `AGENTS.md` or the owning topic document. One skill should do one job; compose skills explicitly rather than hiding a large workflow behind a vague trigger.

## Lifecycle

1. **Propose:** state the repeated problem, trigger, owner, scope, expected benefit, and risks.
2. **Review:** inspect commands, dependencies, network calls, data access, permissions, and side effects. Treat skill content as code.
3. **Test:** run a representative happy path, an invalid-input case, a permission-denied case, an interruption/resume case, and a failure case. Use sandbox data and credentials.
4. **Approve:** record reviewer, version, allowed scope, and human approval. Keep project skills in version control and change them through review.
5. **Publish:** make the skill discoverable only after approval; record precedence and compatibility with the selected tool.
6. **Monitor:** record failures, drift, unsafe requests, and unnecessary context cost. Update the skill when the underlying workflow changes.
7. **Deprecate or remove:** mark the status, provide a replacement or reason, and remove unused skills after dependent references are updated.

Do not let an agent silently install, update, enable, or publish a skill, plugin, MCP server, or executable dependency. Pin versions where possible, verify provenance, and obtain approval for new capability or side effects.

## Safety and composition

- Skills receive the minimum context, credentials, tools, and writable paths needed for their procedure.
- Production credentials and live personal data are never inputs to an agent skill. Production deploy, destructive migration, and irreversible external actions are denied or human-only.
- A skill must stop and ask when a precondition, scope, approval, or required input is missing; it must not guess or broaden its scope.
- Retries are bounded and only automatic for known transient, idempotent failures. Never retry a payment, migration, message, deletion, or other side effect blindly.
- Composition records the order, data passed between skills, ownership of each output, and the verification gate between them.
- Skills must not override `AGENTS.md`, security rules, accepted specs, permissions, or human decisions. Tool precedence is documented in `09_tool-profiles.md`.

## Skill evaluation record

| Skill/version | Scenario | Expected result | Actual result/evidence | Reviewer | Status/date |
|---|---|---|---|---|---|
| `<name>/<version>` | `<task or negative case>` | `<observable outcome>` | `<link or artifact>` | `<role>` | `<approved/failed; date>` |

Review a skill after tool, stack, permission, dependency, or workflow changes, and at a regular interval agreed by the project. A skill with no owner, trigger, verification, or review date is not ready for use.

## Questions to resolve

- Which skills are approved, who owns them, and what is the review cadence?
- Which skills may modify files, run commands, use network access, or invoke external systems?
- How are skills discovered, versioned, pinned, approved, and deprecated by the selected tool?
- Which scenarios, negative tests, and interruption/resume checks are required before publication?
- How are skill failures, unsafe requests, and tool-version drift reported?
