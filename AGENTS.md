# AGENTS.md

## Project Overview

This is a **chezmoi-managed dotfiles repository** for cross-platform system configuration
(macOS, Arch Linux, Debian/Ubuntu, Windows, WSL, GitHub Codespaces). The chezmoi source
root is `home/` (set via `.chezmoiroot`). There is no application build system, test suite,
or CI pipeline -- the project consists of configuration files, shell scripts, Go templates,
and Lua modules.

## Key Commands

### Chezmoi (primary tool)

```bash
chezmoi apply                    # Apply dotfiles to the system
chezmoi apply --dry-run          # Preview changes without applying
chezmoi diff                     # Show diff between source and target
chezmoi edit <file>              # Edit a managed file
chezmoi add <file>               # Add a file to chezmoi management
chezmoi re-add                   # Re-add modified files
chezmoi data                     # Dump template data (useful for debugging)
chezmoi execute-template < file  # Test Go template rendering
```

### Bootstrap

```bash
./install.sh                     # Unix/macOS bootstrap (installs chezmoi + applies)
./install.ps1                    # Windows bootstrap (PowerShell)
```

### Formatters / Spell Check

```bash
stylua .                         # Format all Lua files
biome format --write .           # Format JSON/JS/TS files
cspell "**"                      # Run spell checker (config in .config/cspell.json)
```

### No Tests

There is no test suite. Validate changes by running `chezmoi diff` and `chezmoi apply --dry-run`.

## Repository Structure

```
.chezmoiroot              # Points chezmoi source to home/
home/                     # Chezmoi source root (maps to $HOME)
  .chezmoi.toml.tmpl      # Main chezmoi config (Go template)
  .chezmoidata/           # Data files: common.toml, homebrew.toml, yay.toml
  .chezmoiexternals/      # External git repos/archives (neovim, oh-my-zsh, etc.)
  .chezmoiscripts/        # Platform-specific setup scripts (arch/, darwin/, debian/)
  .chezmoitemplates/      # Reusable Go templates
  private_dot_config/     # XDG config for ~21 tools (wezterm, git, fish, zsh, etc.)
assets/                   # Keychron keyboard configs
install.sh / install.ps1  # Bootstrap scripts
```

## Code Style Guidelines

### General Formatting

- **Encoding:** UTF-8 everywhere
- **Line endings:** LF (Unix) -- enforced in `.editorconfig` and `.stylua.toml`
- **Final newline:** Always insert
- **Trailing whitespace:** Trim (except Markdown)
- **Indentation:** Spaces only, never tabs

| Language         | Indent Size | Max Line Length |
|------------------|-------------|-----------------|
| Lua              | 2           | 120             |
| Bash / Zsh       | 2           | 100             |
| Fish             | 4           | 100             |
| JSON / TOML / YAML | 2        | 120             |
| Markdown         | 2           | 120             |

### Lua (WezTerm configs)

- **Formatter:** StyLua (`.stylua.toml`)
- **Quotes:** Single quotes enforced (`'string'`)
- **Trailing commas:** Always in tables
- **Collapse simple statements:** Always (single-line `if ... then ... end`)
- **Require sorting:** Enabled via StyLua
- **Module pattern:** `local M = {}` ... `return M`
- **Config interface:** Modules expose `M.apply = function(config) ... end`
- **Type annotations:** Use LuaCATS (`---@param`, `---@return`, `---@class`)
- **Type casting:** `--[[@as TypeName]]` on require statements
- **Naming:** `snake_case` for variables and functions; `PascalCase` for types/classes
- **File headers:** ASCII art banner in `--[[ ... --]]` block comments

### Shell Scripts (Bash / Zsh)

- **Shebang:** `#!/usr/bin/env bash` (never `#!/bin/bash`)
- **Strict mode:** `set -eu` or `set -euo pipefail` at script start
- **Functions:** `function name() {` with `local` for all local variables
- **Private functions:** Prefix with underscore (`_internal_func`)
- **Naming:** `snake_case` for functions and local vars; `UPPER_SNAKE_CASE` for env vars
- **Error output:** `echo "message" >&2` for errors
- **Tool checks:** `command -v <tool> >/dev/null` before using optional tools
- **Function docs:** Google Shell Style Guide format (`#######` block with `Globals:`, `Arguments:`, `Outputs:`)
- **Section headers:** `# ------` lines or `#################### Section ####################`

### Fish Shell

- **Indent:** 4 spaces
- **Functions:** `function name --description "Brief description"` ... `end`
- **Private functions:** Prefix with underscore (`_helper_func`)
- **Variables:** `set -l` for local, `set -gx` for exported globals
- **Tool checks:** `if type -q <command>` (Fish idiom)
- **Naming:** `snake_case` for everything

### Chezmoi Templates (Go templates)

- **Whitespace trimming:** Use `{{-` and `-}}` aggressively to control output
- **Variable declarations:** Top of file in a preamble block: `{{- $var := value -}}`
- **Comments:** `{{- /* comment */ -}}`
- **Platform guards:** `{{- if eq .env.os "darwin" }}` / `{{- if not .env.ephemeral }}`
- **Sprig functions:** Use `sortAlpha`, `uniq`, `join`, `concat`, `list` for data manipulation

### JSON

- **Formatter:** Biome (`biome.json`)
- **Indent:** 2 spaces, 120 char line width
- **Schema field:** Include `$schema` where applicable

### TOML Data Files

- **Indent:** 2 spaces
- **Arrays:** One item per line for long lists, single-quoted strings
- **Trailing commas:** Used in arrays
- **Value alignment:** Column-aligned `=` with padding spaces (e.g., starship.toml)

### Git Conventions

- **Commit messages:** Imperative, sentence-case, no conventional commit prefix
  - Good: `Update default model in opencode`, `Fix tree-sitter install on debian`
  - Bad: `feat: updated model`, `fixed stuff`
- **Default branch:** `main`
- **Code owners:** `@m0lson84`, `@michaelo-spindance`

## Cross-Platform Awareness

Configs adapt dynamically based on OS, distro, and environment. When editing templates:

- Check `{{ .chezmoi.os }}` for OS (`darwin`, `linux`, `windows`)
- Check `{{ .chezmoi.osRelease.id }}` for distro (`arch`, `debian`, `ubuntu`)
- Check `{{ .env.ephemeral }}` for ephemeral environments (Codespaces, devcontainers)
- Package data split by platform: `homebrew.toml` (macOS), `yay.toml` (Arch), `common.toml` (shared)

## Secrets Management

- **1Password** integration for credentials (AWS, SSH, etc.)
- **GPG symmetric encryption** for sensitive files
- Never commit plaintext secrets -- use chezmoi templates with 1Password references
