# AGENTS.md

## Project Overview

Personal dotfiles repository for cross-platform system configuration managed by
[chezmoi](https://www.chezmoi.io/). This is **not** an application or library -- it is a
configuration management project. The `home/` directory is the chezmoi source root
(declared in `.chezmoiroot`). Minimum chezmoi version: **2.69.0**.

**Target platforms:** macOS (darwin), Arch Linux, Debian/Ubuntu, WSL, GitHub Codespaces, Dev Containers.

## Commands

```bash
chezmoi apply                              # Apply all managed files to home directory
chezmoi apply --dry-run                    # Preview changes without applying
chezmoi diff                               # Show diff between source and destination
chezmoi managed                            # List all managed files
chezmoi execute-template < file.tmpl       # Render a template to stdout
chezmoi cat-config                         # Show resolved chezmoi config
chezmoi data                               # Show all template data
chezmoi doctor                             # Diagnose common problems
stylua .                                   # Format Lua files (WezTerm configs)
biome format .                             # Format JSON/JS/TS files
```

There are no build, lint, or test commands -- this is a dotfiles repo with no CI pipeline.

## Repository Structure

```
.chezmoiroot          -> declares home/ as the source root
home/
  .chezmoi.toml.tmpl  -> chezmoi config (user data, encryption, OS detection)
  .chezmoidata/       -> TOML data files: common.toml, arch.toml, darwin.toml
  .chezmoiexternals/  -> external git repos and archives (neovim, oh-my-zsh, tmux, zellij)
  .chezmoiignore.tmpl -> OS-conditional ignore rules
  .chezmoiscripts/    -> lifecycle scripts per platform (arch/, darwin/, debian/)
  .chezmoitemplates/  -> reusable shell function snippets (included via {{ template }})
  private_dot_config/ -> 23 application configurations
  private_dot_aws/    -> AWS credential templates (GPG-encrypted)
  source/             -> directory scaffolding for code repos
```

## Template System

Files ending in `.tmpl` use Go `text/template` syntax (chezmoi's engine with Sprig functions).
Key template variables:

| Variable                           | Values / Purpose                                         |
| ---------------------------------- | -------------------------------------------------------- |
| `.env.os`                          | `darwin`, `linux` -- operating system                    |
| `.env.distro`                      | `arch`, `debian`, `ubuntu`, `pop` -- Linux distribution  |
| `.env.wsl`                         | bool -- Windows Subsystem for Linux                      |
| `.env.ephemeral`                   | bool -- Codespaces or dev container                      |
| `.env.homebrew`                    | bool -- Homebrew available                               |
| `.chezmoi.hostname`                | `deep-thought`, `dont-panic` -- machine-specific configs |
| `.name`, `.email`                  | Git user identity                                        |
| `.default.browser/editor/terminal` | Default applications                                     |
| `.personal.*`, `.mhs.*`            | 1Password account details                                |

### Template patterns

- **OS branching:** `{{ if eq .env.os "darwin" }}...{{ end }}`
- **Distro branching:** `{{ if eq .env.distro "arch" }}...{{ end }}`
- **Ephemeral guard:** `{{ if not .env.ephemeral }}...{{ end }}`
- **List construction:** `{{- $items := list "a" "b" -}}` then conditional `concat`
- **Template inclusion:** `{{ template "install-mise.tmpl" . }}` (from `.chezmoitemplates/`)
- **Pipelines:** `{{ $list | sortAlpha | uniq | join " " }}`

## Code Style Guidelines

### Formatting (`.editorconfig`)

- **Charset:** UTF-8, **Line endings:** LF, **Trailing whitespace:** trimmed
- **Max line length:** 120 (general), 100 (shell/fish)
- **Indent:** spaces everywhere (never tabs), **Final newline:** always

| File type                        | Indent size                        |
| -------------------------------- | ---------------------------------- |
| Lua (`*.lua`)                    | 2 spaces                           |
| Shell (`*.bash, *.sh, *.zsh`)    | 2 spaces                           |
| Fish (`*.fish`)                  | 4 spaces                           |
| Config (`*.json, *.toml, *.yml`) | 2 spaces                           |
| Docs (`*.md`)                    | 2 spaces, keep trailing whitespace |

### Lua (WezTerm configs, `.stylua.toml`)

- 2-space indent, 120 column width, Unix line endings, **single quotes**
- Collapse simple statements to one line; sort `require` statements alphabetically
- Modular pattern: each file exports `{ apply = function(config) ... end }`

### JSON / JS / TS (`biome.json`)

- 2-space indent, 120 line width

### Shell scripts (Bash/Zsh)

- Use `set -euo pipefail` (or `set -eu` minimum) at the top of scripts
- Use `function name() {` syntax (not POSIX `name() {`)
- Idempotency: check `command -v` before installing tools
- Quote variables: `"${variable}"`
- Document functions with Google style doc comments

### Fish shell

- 4-space indent, `set -gx` for global exports
- One function per file in `functions/` directory (Fish convention)
- Use `gum` for interactive TUI prompts where appropriate

### Chezmoi templates

- Use `{{- ... -}}` (trimming dashes) to control whitespace
- Define computed variables at the top: `{{- $var := "value" -}}`
- Use conditional reassignment, not nested if/else blocks
- Keep template logic minimal -- delegate to shell functions in `.chezmoitemplates/`
- Name template files descriptively: `install-*.tmpl`, `setup-*.tmpl`, `update-*.tmpl`

### Chezmoi naming conventions

Chezmoi uses filename prefixes to control behavior:

| Prefix                | Meaning                                      |
| --------------------- | -------------------------------------------- |
| `dot_`                | File starts with `.` in target               |
| `private_`            | File permissions set to private              |
| `symlink_`            | Creates a symlink                            |
| `run_once_before_`    | Run script once before apply                 |
| `run_onchange_after_` | Run script when contents change, after apply |
| `run_after_`          | Run script every apply, after                |

### Commit messages

- Imperative mood, lowercase, no conventional commit prefix
- Examples: `Install and manage progressive web apps`, `Use paru on arch systems`
- Keep messages concise (one line, ~50-72 chars)

### Data files (`.chezmoidata/*.toml`)

- `common.toml`: packages shared across all platforms
- `arch.toml` / `darwin.toml`: platform-specific packages
- Package lists use `apps` (GUI) and `tools` (CLI) keys; lists are sorted alphabetically

### Secrets and encryption

- GPG symmetric encryption for sensitive files (AWS credentials)
- 1Password integration for runtime secrets (two accounts: personal + work)
- Never commit plaintext secrets -- use chezmoi templates with `op` lookups
- Guard credential sections with `{{ if not .env.ephemeral }}`

### Three-shell parity

Bash, Zsh, and Fish configs maintain near-identical functionality:

- Same aliases: `cat`->`bat`, `ls`->`eza`, `finder`->`yazi`
- Same environment variables and PATH setup
- Same tool initializations (atuin, fzf, mise, starship, zoxide)
- Fish gets the richest implementations; Bash/Zsh share template structure
