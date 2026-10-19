---
description: Create or update repository-specific AGENTS.md instructions
argument-hint: "[focus or constraints]"
---

Create or update `AGENTS.md` for this repository.

The goal is a compact instruction file that helps future Pi sessions avoid mistakes and ramp up quickly. Every line
should answer: "Would an agent likely miss this without help?" If not, leave it out.

User-provided focus or constraints (honor these):
$ARGUMENTS

## How to investigate

Read the highest-value sources first:

- `README*`, root manifests, workspace config; inspect lockfiles only when relevant
- build, test, lint, formatter, typecheck, and codegen config
- CI workflows and pre-commit / task runner config
- existing instruction files (`AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, `.cursorrules`,
  `.github/copilot-instructions.md`)
- repo-local Pi configuration such as `.pi/settings.json`, `.pi/SYSTEM.md`, and `.pi/APPEND_SYSTEM.md`

If architecture is still unclear after reading config and docs, inspect a small number of representative code files to
find the real entrypoints, package boundaries, and execution flow. Prefer reading the files that explain how the system
is wired together over random leaf files.

Prefer executable sources of truth over prose. If docs conflict with config or scripts, trust the executable source and
only keep what you can verify.

## What to extract

Look for the highest-signal facts for an agent working in this repo:

- exact developer commands, especially non-obvious ones
- how to run a single test, a single package, or a focused verification step
- required command order when it matters, such as `lint -> typecheck -> test`
- monorepo or multi-package boundaries, ownership of major directories, and the real app/library entrypoints
- framework or toolchain quirks: generated code, migrations, codegen, build artifacts, special env loading, dev servers,
  infra deploy flow
- testing quirks: fixtures, integration test prerequisites, snapshot workflows, required services, flaky or expensive
  suites
- important constraints from existing instruction files worth preserving

Good `AGENTS.md` content is usually hard-earned context that took reading multiple files to infer.

## Questions

Only ask the user questions if the repo cannot answer something important. Ask directly in one short batch at most; do
not assume a question tool is available.

Good questions:

- undocumented team conventions
- branch / PR / release expectations
- missing setup or test prerequisites that are known but not written down

Do not ask about anything the repo already makes clear.

## Writing rules

Include only high-signal, repo-specific guidance such as:

- exact commands and shortcuts the agent would otherwise guess wrong
- architecture notes that are not obvious from filenames
- conventions that differ from language or framework defaults
- setup requirements, environment quirks, and operational gotchas
- references to existing instruction sources that matter

Exclude:

- generic software advice
- long tutorials or exhaustive file trees
- obvious language conventions
- speculative claims or anything you could not verify
- content better stored in an existing instruction or documentation file; reference it instead of duplicating it

When in doubt, omit.

Prefer short sections and bullets. If the repo is simple, keep the file simple. If the repo is large, summarize the few
structural facts that actually change how an agent should work.

If `AGENTS.md` already exists at the repository root, improve it in place rather than rewriting blindly. Preserve
verified useful guidance, delete fluff or stale claims, and reconcile it with the current codebase.
