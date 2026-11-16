# Shared Packages and Contracts

**What this covers:** When code goes into `packages/`, how apps on different stacks share contracts (API description, design tokens), and workspace tooling.
**Read this when:** Creating or changing anything in `packages/`, the API contract, or the workspace setup.
**Last updated:** 2026-11-02

This file is a **template**. It contains no stack choices. `ASK:` marks questions for the project's writer. Skip it for single-app projects with nothing shared.

---

## What `packages/` is

`apps/` holds things you run and ship. `packages/` holds libraries that apps import but that are not shipped on their own. Code goes there so it is written once instead of copied into each app.

Common package roles (create only the ones the project needs):

| Package role | Contents | Used by |
|---|---|---|
| Shared UI | Theme, design tokens, shared components | Apps on the same UI stack |
| API client | Code generated from the API description | One per client stack |
| Core | Shared non-UI logic (formatting, validation, common models) | Apps in the same language |
| Tokens source | A language-neutral tokens file that generates each platform's theme | Apps on different UI stacks |

**Rule for what goes in:** keep code inside an app until a second app needs it, then move it to `packages/`. Don't create packages up front for single-app code.

## Sharing across different stacks

Code can't be shared across languages or runtimes. When the project has more than one stack, share **contracts** instead:

- The **API description** (see below) keeps clients and the backend in sync.
- A **tokens file** keeps UI values consistent across platforms.
- **Spec IDs** keep requirements consistent (see `06_specs-and-domain.md`).

Everything else is implemented once per stack, by design.

---

## API contract

A machine-readable API description is the **single source of truth** for the API. `ASK:` which style and format the project uses (for REST, commonly OpenAPI).

- **Direction:** `ASK:` code-first (the API framework generates the description from route schemas) or spec-first. Recommend code-first when the framework supports it, because the description can't drift from the code.
- **Every route has a schema.** Rule for the API app's `AGENTS.md`: no route without a schema.
- The API exports the description, and it is committed (suggested location: `packages/api_contract/`).
- **Clients are generated** from the description, one per client stack. Apps call typed methods and never hand-write request or response models.
- **CI check:** regenerate the description and fail if it differs from the committed file.
- **Rule in `AGENTS.md`:** never hand-edit generated files; regenerate with `<command>`.
- Database schema types stay internal to the API. Clients never import them; the schemas at the API boundary are the public shapes.
- **Breaking changes** are marked in the commit (`feat(<app>)!:`), and the generated clients are updated in the same change or the follow-up is noted.

---

## Workspace tooling

`ASK:` which tools the stack uses, or recommend:

- Use the ecosystem's own workspace feature where one exists, so all members share one dependency resolution.
- In a repo with several ecosystems, each keeps its own workspace. The root `AGENTS.md` lists the commands for each side by side.
- Add a task runner only if the combined command list gets long.
- Verify the exact commands and minimum tool versions against current docs for the installed versions.

---

## Example (language-neutral): one shared component, two apps

```
apps/
  app-one/    depends on packages/ui, supplies its own token values
  app-two/    depends on packages/ui, supplies its own token values
packages/
  ui/         shared button reads its height from the theme tokens
```

The shared button reads a token for its height. `app-one` supplies a normal value and `app-two` supplies a larger one for bigger touch targets. It is the same component with different values, so a design rule like "this app has larger touch targets" lives in tokens, not in a duplicated component.

When the shared component changes, every app that depends on it picks up the change on the next build. A breaking change (for example a new required parameter) breaks the build of every consumer immediately, instead of breaking in production.

---

## Notes for agents

- `packages/*/AGENTS.md`: "Changes here affect every app. Run tests for each consumer after any change. Don't add app-specific code here."
- Root `AGENTS.md`: "Check `packages/` before writing a new component or helper so existing code is reused."

---

## Questions to ask when instantiating

- Which stacks does each app use? One UI stack or several?
- Which workspace tool and package manager per ecosystem?
- Contract style and format, and code-first or spec-first?
- Is anything shared enough to deserve a package now, or should it wait for a second consumer?
