#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Install additional tools
# ---------------------------------------------------------------------------

#######################################
# Install fzf
#######################################
function install_fzf() {
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --bin
}

#######################################
# Install GitHub CLI
#######################################
function install_github_cli() {
  echo "Installing GitHub CLI..."

  # Download GPG key
  tmp_key=$(mktemp)
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "$tmp_key"
  sudo cp "$tmp_key" /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  rm -rf "$tmp_key"

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
# Install lazygit
# Arguments:
#   version: The version to install
#######################################
function install_lazygit() {
  echo "Installing lazygit..."
  local version=$1

  case "$(uname -m)" in
    x86_64) asset_name="lazygit_${version}_Linux_x86_64" ;;
    aarch64 | arm64) asset_name="lazygit_${version}_Linux_arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" ;;
  esac

  asset_file="$asset_name.tar.gz"
  download_url="https://github.com/jesseduffield/lazygit/releases/download/v$version/$asset_file"

  echo "Downloading $asset_file..."
  tmp_key=$(mktemp -d)
  archive_path="$tmp_key/archive.tar.gz"
  curl -L "$download_url" -o "$archive_path"

  echo "Extracting $asset_file..."
  tar -xzf "$archive_path" -C "$tmp_key"
  rm -f "$archive_path"

  echo "Installing lazygit..."
  install_dir="$HOME/.local/bin"
  mv "$tmp_key/lazygit" "$install_dir/lazygit"
  chmod +x "$install_dir/lazygit"
  rm -rf "$tmp_key"
}

#######################################
# Install language runtimes
#######################################
function install_runtimes() {
  local langs=("$@")

  echo "Installing language runtimes..."
  mise i "${langs[@]}"
}

#######################################
# Install zellij
#######################################
function install_zellij() {
  echo "Installing zellij..."
  cargo install --locked zellij
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

# Install additional tools
install_fzf
install_github_cli
install_lazygit "0.48.0"
# install_zellij
