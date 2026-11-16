# Tool Profiles

**What this covers:** What the plan needs from any AI coding tool, plus reference profiles for specific tools (a coding agent, a worktree orchestrator, and one more agent) and a generic fallback.
**Read this when:** Choosing or changing tools, setting up agent permissions or skills for a tool, setting up parallel worktrees, or debugging why an agent didn't load a file.
**Last updated:** 2026-11-07 (Hermes context-limit guidance verified against v0.22.5; Orca workflow checked 2026-11-03; re-check tool facts after upgrades)

---

## How the plan treats tools

- Every other file in this set is **tool-agnostic**. Tool-specific facts live only in this file, each with a verified date.
- The profiles below are **reference material**. `ASK:` which tools and orchestrator the writer uses, and keep only those profiles in a project's copy.
- Several unrelated projects are called "Orca". The Orca profile here means **stablyai/orca**, the agent IDE and orchestrator that lists Hermes Agent as a supported agent. Confirm which one the writer uses.
- Tool docs change quickly. Treat each profile as a starting point and run the loading check (below) on the installed versions.

---

## What the plan needs from any tool

| # | Need | Why it matters | Where it's used |
|---|---|---|---|
| 1 | Reads the root `AGENTS.md` | The router and shared rules | `01`, `08` |
| 2 | Loads nested `AGENTS.md` files (eagerly or lazily) | App-specific rules; decides whether the "list the directory first" rule is needed | `01`, `08` |
| 3 | Reads project-level skills from `.agents/skills/` | Procedures load on demand | `01`, `07` |
| 4 | Has a permission or approval mechanism with a hard deny | Enforces Boundaries | `07` |
| 5 | Caps context file size (or not) | Keeps files under the cap | `01`, `08` |
| 6 | Handles isolated workspaces/worktrees and shared-resource coordination | Parallel work, state isolation, env/ports, safe promotion | below |
| 7 | Supports bounded loops, checkpoint/resume, cancellation, budgets, context-budget handoff, and run evidence | Harness safety and recovery (`21`) |
| 8 | Supports delegation/worker limits and exposes task status, failure, and result handles | Multi-agent integration (`22`) |
| 9 | Provides evaluation hooks or a way to run repeatable success/negative tests | Capability approval (`23`) |
| 10 | Defines skill precedence, write/install approval, versioning, and capability boundaries | Skill governance (`20`) |

---

## Hermes Agent (coding agent)

Verified 2026-11-07 against the installed Hermes Agent v0.22.5, its source, and current Hermes documentation; re-check after upgrades.

- **Context files:** only one type loads, first match wins: `.hermes.md`, then `AGENTS.md`, then `CLAUDE.md`, then `.cursorrules`. Consequence: **never create a `.hermes.md`**, or it replaces `AGENTS.md`. With `AGENTS.md` present, no `CLAUDE.md` bridge is needed.
- **Nested `AGENTS.md`:** the configuration docs say `AGENTS.md` is hierarchical and subdirectory files are combined, while Hermes' own repo says each area's `AGENTS.md` loads automatically when you work in that directory. The docs page is older, so behavior may differ by version. Run the loading check to see which applies. Until you know, keep the "list the directory first" rule in the root file.
- **Size cap:** context files are capped at `context_file_max_chars` (default 20,000 characters) with smart truncation. The root skeleton in `08` is about 6,500 characters, so there is room, but keep each file well under the cap.
- **Skills:** project-local skills are read from `<project-root>/.hermes/skills/` and `<project-root>/.agents/skills/`. The project root is the nearest ancestor containing `.git`, and worktrees count. Project skills have the highest precedence (project, then `~/.hermes/skills/`, then external dirs). So the plan's `.agents/skills/` location works as is.
- **Self-improving skills:** Hermes can create and edit its own skills (into `~/.hermes/skills/` by default). There is a setting to stage skill writes for approval (`skills.write_approval`, reviewed with `/skills pending`, `/skills approve`, `/skills reject`). Recommended: turn approval on, and move skills worth keeping into the repo's `.agents/skills/` through a pull request. Repo skills win on conflict.
- **Memory and persona live outside the repo** (`~/.hermes/memories/`, `SOUL.md`). Repo docs win on conflict (precedence rule in `07`). Don't leave project rules only in memory.
- **Messaging gateway:** Hermes can be reached through messaging platforms, and messages become instructions. If you enable it, restrict who can message the agent (allowed users, pairing; verify the settings in the Hermes security docs) and keep it off for sessions with access to sensitive repos or credentials.
- **Permissions are user-level**, in `~/.hermes/config.yaml`: `approvals.mode` (`manual`, `smart`, or `off`) and `command_allowlist` (patterns). Because this lives outside the repo, it can't be committed. See the per-developer checklist below.
- **Custom provider context limits:** proxies and model aliases may enforce smaller request ceilings than model-family metadata and may omit limit fields. Pin the verified route limit in `model.context_length` or the matching custom-provider model entry; keep `compression.enabled: true` and set `compression.threshold_tokens` below the effective input budget after output reservation. Hermes raises the percentage trigger to at least 75% below 512K only when the configured ratio is lower; `compression.threshold_tokens` caps that derived trigger downward and is useful for small proxy limits. For an observed 180K ceiling, `120000` is only an example if adequate headroom remains. Verify with `hermes config get`, `hermes config check`, `hermes prompt-size`, and session `/usage`. A context-limit HTTP 400 is deterministic: compact once to recover, do not retry unchanged history, then fix the route limit/trigger. Per-turn `compression.micro_compact` is not the fix; it rewrites history each turn and can break prompt-cache prefixes.

### Hermes as PM/coordinator

- Hermes `/goal` can continue the PM's demo objective across turns; it is not a replacement for the worker lifecycle maintained by an external orchestrator.
- Hermes `delegate_task` creates fresh child agent contexts with separate terminal sessions. Use it for Hermes-native workers when the intake selects that model.
- When Hermes controls Orca, give the PM access to the verified Orca orchestration skill/CLI and pass the objective, task contract, scope, budgets, and expected evidence explicitly. Treat Orca task/dispatch state as authoritative for worker lifecycle.
- Verify the exact Hermes and Orca versions before relying on command, profile, credential, or session behavior.

## Orca (orchestrator)

Verified 2026-11-03 against Orca's official CLI documentation; re-check after upgrades.

- Orca launches CLI agents in a selected worktree: this may be the current worktree or a new isolated worktree. Choose a new isolated worktree for parallel writers unless shared-workspace coordination is explicitly designed. Orca doesn't read instruction files itself; the agent inside the worktree does.
- **Only committed files exist in a new worktree.** `AGENTS.md`, `.agents/skills/`, `orca.yaml`, and `.worktreeinclude` must be committed.
- **Gitignored files are missing** (local env files) unless carried over. A `.worktreeinclude` file at the repo root lists gitignored paths that are copied into every new worktree. Per Boundaries, list **dev and sandbox files only**.
- **Setup hooks** run after a worktree is created (install dependencies, copy env files) and come from a committed `orca.yaml` or from local settings (Settings, Repository, Worktree Hooks). `orca.yaml` is read from the new worktree, so it has to be committed. Hook scripts get `$ORCA_ROOT_PATH` and `$ORCA_WORKTREE_PATH`.
- **Worktrees live under `~/orca/workspaces/<project>/<name>`**, not next to the repo, so relative paths like `../main/.env` break. Use the environment variables.
- **Verify after upgrades.** Users have reported setup scripts silently not running after an update. Check a fresh worktree for dependencies and env files.
- Optional: an Orca CLI skill lets agents create worktrees and drive Orca themselves.

### Orca tracked orchestration workflow

Use tracked orchestration when the coordinator needs ownership, completion tracking, dependencies, worker messages, or decision gates. First confirm that the Orca runtime is available (`orca status --json`) and load the installed guide (`orca skills get orchestration --full`). Do not invent flags from memory.

The current conceptual sequence is:

1. Create a durable Run with an objective.
2. Create Tasks with clear specs, titles, dependencies, budgets, and expected evidence.
3. Start a worker Dispatch on the current or a new isolated worktree, selecting the approved agent and setup policy.
4. Wait for `worker_done`, `escalation`, or `question` messages; include both task and dispatch IDs in lifecycle messages.
5. Read the worker result and actual worktree/diff, then release, retain, stop, retry, or follow up using the verified Orca command for that lifecycle action.
6. Use coordinator questions and explicit decision gates when a worker is blocked on a decision.
7. Integrate with one designated owner and rerun the demo smoke test and relevant checks before marking the parent objective complete.

The official CLI examples currently use `orca orchestration run-create`, `task-create`, `worker-start`, `check --wait`, `send`, `worker-show`/`worker-read`, and gate commands. A Run is a durable namespace/inbox; it does not schedule or place workers—the coordinator decides when and where to dispatch. The older `orca orchestration run`/`run-stop` flow is retired in current docs. Re-read the live guide after Orca upgrades; this profile is a routing aid, not a substitute for installed-version verification.

### Orca scheduled automation

Use Orca scheduled automations for recurring demo tasks such as triage, review, or maintenance—not as an implicit replacement for a supervised Run/task/worker workflow. Create the automation disabled first, inspect its configuration, run it manually against synthetic data or a sandbox, and enable it only after the owner approves the contract in the project intake.

Record the trigger and timezone, prompt revision, provider/model, repository or workspace target, setup behavior, allowed tools and permissions, data boundary, expected output/evidence, timeout and retry policy, duplicate handling, alert owner, and disable/reset path. Give recurring automations a bounded objective; they must stop or escalate on missing inputs, repeated failures, scope expansion, protected paths, live credentials, real client data, production access, regulated behavior, or external side effects.

The current CLI surface uses `orca automations list --json`, `orca automations create --disabled`, `orca automations run <automationId> --json`, `orca automations runs --id <automationId> --json`, and the corresponding inspect/update/remove commands. Verify the installed help and prefer `--json` for agent calls. Do not enable a recurring automation merely because its prompt was saved; verify a real sandbox run, its evidence, and the reset path first.

Official references: [Orchestration](https://www.onorca.dev/docs/cli/orchestration), [Scheduled automations](https://www.onorca.dev/docs/cli/automations), and [CLI overview](https://www.onorca.dev/docs/cli/overview).

---

## Parallel-agent rules (any parallel setup)

Several agents editing at once create collisions that a single agent never has. Apply these when using an orchestrator or any similar setup:

- **One owner per progress item.** An agent updates `docs/progress.md` only for the item it was assigned, one line. Otherwise leave the update to a human at merge.
- **Unique names for new files** that agents create in parallel, such as decisions: `docs/decisions/YYYY-MM-DD-<slug>.md`.
- **Own port and own test database per worktree.** Derive them from the worktree or branch name. Otherwise dev servers and integration tests collide. State the pattern in `docs/testing.md`.
- **Shared staging resources:** no concurrent migrations. Migrations run from one place, one at a time.
- **Secrets:** carry over dev and sandbox env files only.

Optional block for the root `AGENTS.md` (also in `08`):

```md
## Parallel work
- You may be one of several agents, each in its own git worktree. Stay inside your worktree.
- Use the port and test database name from your worktree's env. Never share them.
- Update docs/progress.md only for the item you were assigned.
```

---

## Loading check (run on each tool and version)

In a fresh worktree, ask the agent:

1. "List every instruction file you have loaded, with its first line." Expect the root `AGENTS.md`.
2. "List the skills you can see." Expect the `.agents/skills/` entries.
3. Have it read one file inside an app, then ask again which instruction files are loaded. If the app's `AGENTS.md` appears only now, nested loading is lazy and the "list the directory first" rule is needed.
4. Ask it to read a file named `.env`. Expect a refusal or denial.
5. Ask it to run the production deploy script. Expect a denial.

If any answer is wrong, fix the cause (committed files, permission config, naming) before relying on the setup.

---

## Per-developer setup checklist (for tools with user-level config)

**Hermes (each developer applies it, because config is user-level):**

- `approvals.mode` set to `manual` or `smart`, never `off`.
- `command_allowlist` limited to safe commands (test, lint, format). Never allowlist `deploy:prod` or `migrate:prod`.
- Skill write approval turned on.
- No `.hermes.md` in the repo.

**Orca (committed to the repo):**

- `orca.yaml` with a setup hook that installs dependencies.
- `.worktreeinclude` listing dev and sandbox env files only.
- Check a fresh worktree after every Orca upgrade.

**Repo:** `AGENTS.md` files and `.agents/skills/` committed.

---

## OpenCode (reference profile)

Verified 2026-10-21 against OpenCode docs. Docs differ between versions, so check the installed version.

- **Only `AGENTS.md` is discovered** in current docs; the old `CLAUDE.md` fallback no longer applies.
- **Ambient discovery:** loads every `AGENTS.md` from the directory it was started in up to the project root.
- **Nested files load lazily:** an `AGENTS.md` below the starting directory is picked up when the agent reads a file or lists a directory there, once per session. Editing it mid-session does not update the injected copy.
- **Skills:** searches `.agents/skills/<name>/SKILL.md` in the project (also `.opencode/skills` and `.claude/skills`), walking up from the current directory to the git root. Skills are listed to the agent and loaded on demand.
- **`instructions` in `opencode.json`** accepts file paths and globs, and listed files are added to what loads at session start. Don't list `docs/*.md` there.
- **Permissions** in `opencode.json`: `allow`, `ask`, or `deny` per tool. Most default to allow; reading `.env` files is denied by default (`*.env` and `*.env.*` denied, `*.env.example` allowed). Those patterns match `.env`-style names only, so other local secret file names need explicit deny rules. In auto-approve mode, explicit `deny` rules are still enforced. Deny rules can sometimes be bypassed through shell commands, so keep production secrets out of the working directory.

Sketch (verify syntax):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "read": {
      "*.env": "deny",
      "*.env.*": "deny",
      "*.env.example": "allow",
      "<other local secret file pattern>": "deny",
      "**/*.pem": "deny",
      "**/*.key": "deny",
      "**/*.jks": "deny",
      "**/*.keystore": "deny"
    },
    "bash": {
      "*": "ask",
      "<production deploy script pattern>": "deny",
      "<production migration script pattern>": "deny"
    }
  }
}
```

---

## Generic fallback (any other tool)

1. Fill in the ten-row capability contract table above from the tool's docs.
2. Run the loading check.
3. If the tool doesn't read `AGENTS.md`, add the bridge it needs (for example a one-line file that imports `AGENTS.md`), and never duplicate the content.
4. If it doesn't read `.agents/skills/`, symlink or sync that folder to the location it does read.
5. Add a profile section here with a verified date.
