#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Install additional tools
# ---------------------------------------------------------------------------

#######################################
# Install developer tools
# Arguments:
#   tools: List of tools to install
#######################################
function install_devtools() {
  local tools=("$@")

  echo "Installing developer tools..."
  mise use -g "${tools[@]}"
}

#######################################
# Install GitHub CLI
#######################################
function install_github_cli() {
  echo "Installing GitHub CLI..."

  # Download GPG key
  tmp_dir=$(mktemp)
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "$tmp_dir"
  sudo cp "$tmp_dir" /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  rm -rf "$tmp_dir"

  # Add the APT repository
  arch="$(dpkg --print-architecture)"
  echo "deb [arch=$arch signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" |
    sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  # Install GitHub CLI
  sudo apt update
  sudo apt install gh -y
}

#######################################
# Install language runtimes
# Arguments:
#   langs: List of languages to install
#######################################
function install_runtimes() {
  local langs=("$@")

  echo "Installing language runtimes..."
  mise i "${langs[@]}"
}

#######################################
# Install the tree-sitter CLI
#######################################
function install_treesitter() {
  echo "Installing tree-sitter CLI..."
  sudo apt install -y clang
  cargo install --locked tree-sitter-cli
}

#######################################
# Install zellij
#######################################
function install_zellij() {
  echo "Installing zellij..."
  cargo binstall --disable-telemetry --no-confirm zellij
}

#################### Main Program ####################

# Stop script on error
set -euo pipefail

# Rust configuration
if [ -f "$HOME/.cargo/env" ]; then
  source "$HOME/.cargo/env"
fi

# Install language runtimes
install_runtimes go node python

# Install dev tools
install_devtools bat eza fd fzf lazygit zoxide

# Install additional tools
install_github_cli
install_treesitter
install_zellij
