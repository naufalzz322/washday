# Documentation and Demo Walkthroughs

**What this covers:** Human-facing documentation, generated API references, and repeatable demo walkthroughs.
**Read this when:** Adding or changing an endpoint, writing setup/run instructions, or preparing presenter scenarios.
**Last updated:** 2026-11-02

This file is a **template**. It contains no stack choices. `ASK:` marks questions for the project's writer.

Principle: anything that can be generated from code stays generated. Markdown covers only what the generator can't say.

---

## Where things live

```
README.md                            # root and each app: for humans (what it is, setup, run)
<api-description file>               # generated, never hand-edited (for REST, commonly OpenAPI)
docs/
  api-contract.md                    # API conventions, not an endpoint list
  realtime.md                        # only if the project uses realtime channels
  runbooks/                          # deploy, rollback, backup-restore, incident (one file each)
  demo-walkthrough-and-reset.md      # primary story, steps, expected results, reset
  demo-data-and-safety.md            # data and sharing rules, when applicable
  user-guides/                       # manuals for each user role, if a deliverable
```

`README.md` is for humans and `AGENTS.md` is for agents. `AGENTS.md` links to the README instead of repeating setup steps.

---

## API endpoint documentation

**Endpoint docs are never hand-written in markdown.** They are the generated API description rendered by a reference UI.

- `ASK:` which API style and description format the project uses (for REST, commonly OpenAPI). If the API framework can generate the description from route schemas, recommend code-first. If there is a spec-first process, follow it.
- `ASK:` which reference UI to use, or recommend one that works with the chosen description format.
- Serve the reference on dev and staging. Decide whether to protect or disable it in production.
- A sparse description produces poor docs in any renderer, so quality lives in the schemas: every route has a summary, a description, examples, and every error response.

**`docs/api-contract.md` holds conventions only** (what the description can't express):

- Auth, and how roles scope data (for example a user sees only their own records)
- Error shape and codes; pagination and filtering conventions
- Idempotency keys on critical operations (for example checkout or payment)
- Webhook rules, if used: signature check, retries, duplicates, out-of-order delivery
- Money, timestamp, and timezone formats
- Versioning, and the forced-update policy for mobile clients if there are any
- Rate limits

Most API description formats don't model realtime channels well. If realtime is used, document the event contract in `docs/realtime.md`.

**Agent reading rule:** the API description grows large. Never open it whole; search it (grep or jq) for the path you need.

**Change workflow:**

1. Change the route's schema and its summary, description, examples, and error responses.
2. Regenerate the API description and commit it.
3. CI regenerates it and fails if it differs from the committed file.
4. A breaking change uses `feat(<app>)!:` in the commit and updates the generated clients in the same change, or notes the follow-up. Mark deprecations in the description.

---

## Demo walkthroughs

The walkthrough is a human-run, reproducible story—not a formal acceptance test. Automated tests cover code behavior; the walkthrough confirms that the intended audience can see the intended outcome in the demo environment.

Store the primary scenario in `docs/demo-walkthrough-and-reset.md`. Each scenario records:

- audience goal and expected visible outcome;
- starting state, environment, actor/role, and seed/reset procedure;
- numbered actions and concrete expected results;
- mocked, simulated, disabled, or incomplete behavior;
- actual run result, date, build/commit, environment, owner, and follow-up issue when run.

Keep scenario files stable and record run results separately in project-owned progress/issues when useful. Agents may draft and update scenarios, but must not claim a run passed without actual evidence or treat a demo run as an approval.

For accessibility and performance, use the applicable checks in `04_testing.md`; record the environment, method, result, and owner. Do not treat an unrepresentative local timing or a successful walkthrough as production evidence.

**Scenario format:**

```md
# Demo walkthrough: <flow name>
What this covers: <one line>.
Read this when: writing, updating, or running this demo scenario.
Role: <role> (<app>). Environment: <local/sandbox/preview>.
Preconditions: <accounts, data>.

## DEMO-<APP>-<AREA>-01 <scenario title>
1. <step>
2. <step>
3. <step>
Expected: <observable result, using the user-facing labels>.
Reset/recovery: <safe procedure>.
Disclosures: <mocked, simulated, disabled, or incomplete behavior>.
Last verified: <date, build/commit, environment, owner>.
```

---

## Runbooks and user guides

- **Runbooks** (`docs/runbooks/`): one short procedure per file when the demo has deployment, environment, migration, incident, or recovery operations. Reset safety is described in `demo-walkthrough-and-reset.md`.
- **User guides** (`docs/user-guides/`): only if they are a deliverable. Write them in the users' language.

---

## Rules to add to root `AGENTS.md`

```md
## Documentation
- Never hand-write endpoint docs. Change the route's schema (summary, description, examples, error responses), regenerate the API description, and commit it.
- Don't open the full API description; search it for the path you need.
- When behavior changes, update the one doc that owns it, in the same change. Don't copy facts into several docs.
- Demo walkthroughs: you may draft and update scenarios, but record actual run results and limitations only when someone has run them; never claim a human approval.
- Humans read README.md. Link to it; don't duplicate it here.
```

## Router rows to add

| If you're working on... | Read |
|---|---|
| Adding or changing an endpoint | docs/api-contract.md (conventions); the generated description is the endpoint reference |
| Realtime events (if used) | docs/realtime.md |
| Deploy, rollback, restore | docs/runbooks/ |
| Writing or updating demo scenarios | docs/demo-walkthrough-and-reset.md |

---

## Questions to ask when instantiating

- Who owns and verifies the primary demo walkthrough?
- Which API style and description format, and which reference UI?
- Is the API reference exposed in production (protected) or disabled?
- Are user guides a deliverable, and in which language?
- What baseline, reset procedure, and disclosure notes must each scenario include?
