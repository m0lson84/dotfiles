# Repository Guide

## Chezmoi Layout

- `.chezmoiroot` makes `home/` the chezmoi source root; paths under it map to `$HOME`, not to a
  literal `home/` directory.
- `.chezmoiversion` requires chezmoi 2.69.0 or newer.
- `home/.chezmoi.toml.tmpl` defines template data. Use `.env.*`, `.system.*`, `.default.*`,
  `.name`, and `.email` as defined there; do not infer host/platform values elsewhere.
- Common, Arch, and Darwin package lists live in `home/.chezmoidata/`. Installation flow lives in
  `home/.chezmoiscripts/<platform>/` and shared functions in `home/.chezmoitemplates/`.
- `home/.chezmoiignore.tmpl` excludes platform- and ephemeral-only paths. Check it before assuming
  a managed file reaches every target.
- `home/.chezmoiexternals/` owns downloaded Neovim, Oh My Zsh, tmux, and zellij content. Edit those
  declarations rather than generated destination trees.

## Safe Verification

- Render one template with `chezmoi execute-template < home/path/file.tmpl`.
- Inspect resolved context with `chezmoi data` and `chezmoi cat-config`; inspect destination changes
  with `chezmoi diff`.
- Do not use `chezmoi apply` as routine validation. Lifecycle scripts install packages and tools;
  Darwin also runs `brew update`/`brew upgrade` on every apply.
- Changes to `run_once_*` scripts do not rerun on initialized machines. Use explicit `chezmoi state`
  handling only when replay is intended.
- No automated test or CI suite exists. Validate changed templates individually and use
  `chezmoi diff` for affected managed outputs.

## Formatting

- `.editorconfig` is authoritative: 4 spaces and 100 columns for shell/Fish; 2 spaces and 120
  columns for Lua and config files.
- Lua check: `stylua --check home/private_dot_config/wezterm` (`stylua` may be absent until managed
  tools are installed).
- Biome covers JSON-like files, but `biome check .` fails on Zed's comment-bearing `settings.json`;
  run Biome only on changed compatible files.

## Configuration Gotchas

- `.opencode/opencode.json` is repository-local OpenCode config.
  `home/private_dot_config/opencode/opencode.json` deploys to global
  `~/.config/opencode/opencode.json`; do not confuse their scopes.
- AWS templates call 1Password at render time and are skipped in ephemeral environments. Avoid
  broad rendering when credentials are unnecessary.
- `install.sh` and `install.ps1` bootstrap chezmoi and immediately run
  `init --apply --source=<repo>`; they are installation entrypoints, not checks.
