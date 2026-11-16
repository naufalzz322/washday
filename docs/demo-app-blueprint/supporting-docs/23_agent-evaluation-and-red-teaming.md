# Agent Evaluation and Red Teaming

**What this covers:** Evaluation and adversarial testing for skills, agent loops, harnesses, and multi-agent coordination before they are trusted with project work.
**Read this when:** Approving an agent capability, changing a skill or harness, adding tools, reviewing autonomous behavior, or investigating an unsafe or poor result.
**Last updated:** 2026-11-02

This file is a tool-agnostic blueprint. Instantiate it as `docs/agent-evaluation-and-red-teaming.md`; tool-specific evaluation commands and telemetry belong in `09_tool-profiles.md`.

## Evaluation gates

Do not approve an agent capability based only on a successful demonstration. Evaluate the exact version, instructions, skills, tools, permissions, model/runtime, and environment that will be used.

| Gate | Scenario | Expected behavior | Evidence | Owner | Status / approval |
|---|---|---|---|---|---|
| Happy path | `<representative task>` | `<correct bounded result>` | `<run/artifact>` | `<role>` | `<status>` |
| Invalid input | `<missing/wrong input>` | `<rejects or asks>` | `<run/artifact>` | `<role>` | `<status>` |
| Permission denial | `<secret/protected/production action>` | `<hard denial or human gate>` | `<log>` | `<role>` | `<status>` |
| Scope expansion | `<prompt asks unrelated action>` | `<stops and asks>` | `<log>` | `<role>` | `<status>` |
| Interruption/resume | `<stop during task>` | `<safe checkpoint and verified resume>` | `<checkpoint/run>` | `<role>` | `<status>` |
| Failure/retry | `<transient or deterministic failure>` | `<bounded, classified recovery>` | `<log>` | `<role>` | `<status>` |
| Conflicting output | `<two agents disagree>` | `<preserves evidence and escalates>` | `<review record>` | `<role>` | `<status>` |

## Red-team scenarios

Test content and tool paths that could cause unsafe behavior:

- Prompt injection in repository files, web pages, issues, generated output, tool results, external agent messages, or data fields.
- Requests to reveal secrets, credentials, private data, hidden instructions, system prompts, or internal traces.
- Requests to bypass permissions, read denied files through an alternate command, deploy, run a production migration, or use live credentials.
- Malformed, oversized, adversarial, or ambiguous inputs; path traversal; shell metacharacters; poisoned dependencies; lookalike packages; and untrusted generated code.
- Conflicting user, repository, tool, agent, or source-document instructions; stale checkpoints; altered worktrees; unexpected external state; and duplicate side effects.
- Excessive delegation, recursive spawning, agent collusion, duplicated work, shared-resource contention, unbounded retries, budget exhaustion, and misleading completion claims.
- Sensitive changes to auth, payments, privacy, migrations, CI, dependencies, legal/compliance, or production operations.

The expected result is a safe refusal, bounded escalation, or human gate—not a plausible-looking partial action.

## Quality, safety, and cost measures

Define thresholds before approval where applicable: acceptance-criterion coverage, factual or test correctness, unsupported-claim rate, unsafe-action rate, permission-denial rate, prompt-injection resistance, retry count, latency, token/tool cost, changed-file scope, and human-review burden. Record false positives and false negatives; a refusal that blocks safe work is a quality issue, not automatically a success.

## Approval and maintenance

- Test every material change to a skill, harness, model/runtime, tool, permission policy, prompt, dependency, or orchestration configuration.
- Maintain a versioned regression suite with representative project tasks and adversarial cases. Keep fixtures sanitized and secrets-free.
- Block use or sharing when a critical safety gate fails, evidence is missing, scope is exceeded, or the evaluator cannot reproduce the result.
- Record exceptions with risk, compensating controls, expiry/review date, and authorized human approval. Do not lower the threshold after a failure without documenting the decision.
- Review results after incidents, repeated unsupported claims, tool upgrades, security changes, or a change in the project’s data classification.

## Questions to resolve

- Which agent capabilities, tools, skills, and workflows require evaluation before use?
- Which tasks and adversarial fixtures represent the project’s real risks?
- What quality, safety, cost, latency, coverage, and denial thresholds apply?
- Who owns the evaluation suite, approves exceptions, and decides whether a failed gate blocks delivery?
- How are evaluation artifacts, logs, prompts, model/tool versions, and regression results retained and redacted?
