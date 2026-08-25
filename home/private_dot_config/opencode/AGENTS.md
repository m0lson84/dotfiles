# Global Rules

## Context discipline

Context volume is ~125x output volume and ~80% of cost. Anything read stays in
context and is re-billed as cached input on every later turn.

- Never read `node_modules/`, `dist/`, lockfiles, or generated `.d.ts`. Get
  versions from `package.json`; locate code with `grep`.
- Use `offset`/`limit` beyond ~400 lines. Do not re-read a file already read in
  this session unless it changed.
- Prefer `grep`/`glob` to locate code over reading files to find it.
- Delegate multi-file search and open-ended codebase questions to the `explore`
  subagent so large results never enter this session.

## Library docs

Docs are the source of truth for third-party APIs — not installed source, not memory.

- Confirm the API with Context7 before writing or changing code against a
  third-party library, whether or not the user asked about it.
- This is the answer to the `node_modules/` ban above: never infer an API from
  vendored source or generated `.d.ts`.
- Pin the installed version in the library ID (`/org/project/version`) so docs
  match what is installed, not latest.
- Prefer Context7 over `webfetch` for library docs.

## Shell output

- Never dump raw JSON reports into context. Filter `npm audit --json`,
  `tsc --noEmit`, and test output through `jq`, `tail`, or a path scope.
- Scope `git diff`/`git log` to paths; use `--stat` before full diffs.
- Do not run whole-repo linters or formatters to check one file; scope to the
  changed paths.
- Fetch specific doc pages, not index or landing pages.

## Working style

- Batch independent reads and searches into one message.
- Report findings as conclusions, not by quoting large file contents back.
