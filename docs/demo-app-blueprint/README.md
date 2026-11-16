# Demo App Blueprint

A lightweight Markdown kit for creating a demo application that is easy to run, demonstrate, reset, and safely share.

## The three parts

1. `README.md` — explains this kit and how to use it.
2. `PROJECT_SETUP.md` — agent instructions for inspecting a project, asking for decisions, creating project docs, and checking readiness.
3. `supporting-docs/` — topic references opened only when relevant, including a project intake worksheet and demo-specific guidance.

## Use it

1. Copy this entire folder into a project repository. Keep the blueprint folder unchanged.
2. Start an agent in the project repository and have it read `<copied-folder>/PROJECT_SETUP.md` first.
3. Copy `<copied-folder>/supporting-docs/PROJECT_INTAKE.md` to the project root as `PROJECT_INTAKE.md`.
4. Before prototype, system design, frontend, or optional backend work, interview the demo owner about missing audience, walkthrough, feature, design, scope, and safety decisions. Ask focused questions one topic at a time, record source/status, and stop at the applicable gate until the owner confirms the read-back. Follow `supporting-docs/requirements-discovery-and-readiness.md`.
5. Once the applicable gate is confirmed, have the agent complete the project intake and create the project’s real `AGENTS.md`, app docs, tests, demo walkthroughs, demo data/reset mechanism, and setup instructions outside the copied blueprint folder.
6. Use only the supporting topics needed for that demo; do not generate client-delivery paperwork unless the demo's scope or risk requires it.

## Demo safety defaults

- Prefer synthetic data and sandbox services; never place production credentials or live client data in a demo environment.
- Document demo-only shortcuts, disabled features, seeded accounts, and reset behavior.
- Keep ordinary user-facing UI natural; do not repeat internal words such as “demo,” “fixture,” or “simulated” across normal navigation and product content. Put concise, truthful limitations on an information page and beside consequential actions. See `supporting-docs/02_design-md.md`.
- Make walkthrough steps reproducible and provide a known-good reset path.
- For a custom or proxied model, verify its exact request limit and configure automatic compaction below the usable input budget; task checkpoints are separate. See `PROJECT_SETUP.md` and `supporting-docs/09_tool-profiles.md`.
- Keep authentication, authorization, secret handling, dependency hygiene, and human approval boundaries appropriate to the exposure and data risk.
- A demo is not automatically production-ready or client-accepted.
