# Global Instructions

## Context discipline

- Search for relevant paths and symbols before reading files.
- Keep reads focused. Use offset/limit for large files and avoid rereading
  unchanged content already available in the conversation.
- Avoid lockfiles, generated outputs, and dependency trees unless directly
  relevant. Focused inspection of installed documentation or source is
  appropriate when official documentation is insufficient or mismatched.
- Filter noisy command output before bringing it into context.

## Documentation

- Use documentation to verify unfamiliar or version-sensitive behavior,
  configuration, commands, and APIs.
- Prefer Context7 for documentation lookups, matching the installed version
  when available.
- If Context7 lacks the relevant version or topic, consult official
  documentation and state any unresolved version mismatch.
- Do not assume documented behavior or API details solely from memory.

## Validation and formatting

- Scope diffs, tests, linters, and formatters to the affected paths where practical.
- Inspect a diff summary before requesting a large diff.
- After editing, run the project's configured formatter on changed files when
  available and consistent with project instructions.
- Do not install formatters or format unrelated files without approval.
- Report what was checked and any validation that could not be performed.

## Working style

- Batch independent reads and searches when supported.
- Prefer targeted edits to rewriting existing files.
- Keep changes focused on the requested task.
- Report findings as conclusions, not large reproductions of file contents.
