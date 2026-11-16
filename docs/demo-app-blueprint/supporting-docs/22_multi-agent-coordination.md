# Multi-Agent Coordination

**What this covers:** When and how to delegate work to multiple agents, with explicit ownership, isolation, dependency control, integration, review, and recovery.
**Read this when:** Planning parallel agent work, designing an orchestrator, delegating tasks, merging agent changes, or resolving agent conflicts.
**Last updated:** 2026-11-03

This file is a tool-agnostic blueprint. Instantiate it as `docs/multi-agent-coordination.md`; orchestrator-specific worktrees, APIs, configuration, and lifecycle behavior belong in `09_tool-profiles.md`.

## Recommended PM/coordinator topology

Use one authoritative coordinator for a multi-agent effort:

```text
PM/coordinator
    -> demo objective, completion contract, task graph, review, and integration
Orchestration layer (Orca or another ADE, when selected)
    -> tracks and coordinates the Run, Tasks, Dispatches, worker sessions, messages, gates, and lifecycle status
Workers
    -> bounded implementation, testing, research, review, or demo-preparation tasks
```

- If Hermes is the PM, Hermes owns the plan and decisions; the selected ADE owns worker lifecycle and dispatch state. Do not let two systems independently retry, merge, or declare the same task complete.
- When Orca is selected, use one durable Run, represent work as Tasks, treat each worker execution as a Dispatch, and include the task and dispatch IDs in worker reports.
- Treat `worker_done`, failure, escalation, question, and gate messages as lifecycle events; verify the actual diff, files, tests, walkthrough, and evidence before updating the parent task.
- Use a single designated integrator for shared changes. Parallel writers stay in isolated worktrees or equivalent workspaces; reviewers do not modify the writer's workspace.
- If the project uses only Hermes-native delegation or a different ADE, preserve this contract and substitute that tool's verified lifecycle primitives.

## Default phase sequence

The default dependency chain is:

```text
Prototype -> Frontend -> Backend
```

- Prototype work defines the audience outcome, multipage page/screen inventory, linked primary walkthrough, interaction behavior, scope, limitations, and any backend behavior the demo may need. End the phase with an owner-reviewed prototype or equivalent story evidence.
- Frontend work builds the walkthrough against synthetic fixtures, mocks, or stubs. End the phase with a clean/reset smoke test and documented backend assumptions.
- Backend work is optional when the demo can honestly remain fixture-backed. If it is in scope, implement the sandbox service, data, or integration after frontend verification, then rerun the end-to-end walkthrough and document remaining simulation.
- The coordinator verifies each phase gate before dispatching the next phase. Parallelize independent work inside a phase only when ownership, files, resources, and merge rules are explicit.
- Backend discovery may happen earlier, but implementation order and any exception must be recorded in the intake.

## Decide whether to parallelize

Parallelize only when tasks can be separated into independently verifiable deliverables with low shared-state contention. Keep work serial when tasks depend on the same files, decisions, schema/migration sequence, production-like environment, or acceptance interpretation. Include orchestration, review, integration, and conflict cost in the decision; more agents do not automatically make work faster or safer.

## Delegation contract

Every delegated task has a stable ID and an explicit contract:

| Field | Required content |
|---|---|
| Goal and context | `<outcome, relevant decisions, source IDs>` |
| Scope | `<allowed paths, tools, environment, data class>` |
| Owner | `<one agent responsible for the deliverable>` |
| Inputs/dependencies | `<verified paths, prerequisite task IDs>` |
| Acceptance | `<observable criteria, tests, evidence>` |
| Constraints | `<no-go paths, human gates, shared resources>` |
| Budget/deadline | `<iterations, time, cost, worker limits>` |
| Handoff | `<files/commit, verification, risks, open questions>` |

Delegate implementation, research, testing, or review with different task IDs and narrowly scoped outputs. Do not delegate an irreversible external action or a human approval to an agent.

## Ownership and isolation

- One owner per task, progress item, decision record, and writable file set. An agent does not edit another owner's files without explicit transfer.
- Prefer isolated worktrees or equivalent isolated workspaces. Each worker has its own branch/worktree, port, test database, temporary files, and logs.
- Only committed or explicitly transferred files are assumed to exist in a new workspace. Verify that required instructions, skills, and non-secret setup files are present.
- Carry only development/test or sandbox credentials through approved mechanisms. Never propagate production secrets or live personal data to workers.
- Assign unique names to concurrently created files. Protect shared state with an explicit lock or single-writer owner.
- Shared staging, test accounts, external sandboxes, and data migrations are coordinated resources; schedule one writer at a time and record lock owner and expiry.

## Dependency and integration control

- Represent task dependencies as a directed acyclic graph; state which tasks can run in parallel and which require a verified predecessor.
- Define shared interfaces and file ownership before dispatch. A task that needs a decision blocks and asks instead of inventing an incompatible contract.
- Limit active agents and delegate depth to configured budgets. Avoid spawning agents that merely repeat the same analysis or recursively delegate without an owner.
- Each worker reports changed paths/commit, commands and tests run, results, evidence, risks, assumptions, open questions, and external side-effect handles.
- The coordinator verifies the actual diff and evidence, integrates in dependency order, resolves conflicts, reruns affected tests, and updates the canonical progress/release records.

## Review and merge gates

- Agent output is untrusted until reviewed. Inspect the diff, dependency changes, generated files, security/privacy impact, scope alignment, and tests.
- Require human review for auth/security, payments, privacy, dependencies, CI/workflow, migrations, licensing/compliance, production operations, and accepted-risk changes.
- Never let one agent report another agent's unverified completion as fact. Read back the artifact, commit, external record, or approval.
- Merge only when success criteria pass, the relevant scope/evidence record is current, required review is recorded, and conflicts are resolved.
- After merge, run the combined change's relevant tests and update one canonical progress item and demo evidence record.

## Failure, cancellation, and recovery

- If a worker fails, times out, or is canceled, mark its task state and inspect its workspace and checkpoint before reassignment.
- Transfer ownership explicitly; tell the replacement agent what was verified and what remains uncertain.
- If two agents change the same contract or shared file, stop integration, designate one owner, reconcile against agreed specs, and rerun affected acceptance checks.
- Cancel redundant or out-of-scope work. Preserve useful partial artifacts with clear status; do not mark the parent task complete until required outputs are verified.
- On orchestration failure, stop spawning, checkpoint the task graph and budgets, verify side effects, then resume only after permissions and ownership are clear.

## Questions to resolve

- Which task classes may be delegated, and which remain single-owner or human-only?
- What isolation model, worker limit, delegation depth, budgets, and cancellation behavior apply?
- How are task IDs, dependency graphs, ownership transfers, shared-resource locks, and conflicts recorded?
- Which changes require independent review or human approval before merge?
- How are partial outputs, timeouts, failed workers, and external side effects reconciled?
