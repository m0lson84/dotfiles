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
  tmp_dir=$(mktemp -d)
  archive_path="$tmp_dir/archive.tar.gz"
  curl -L "$download_url" -o "$archive_path"

  echo "Extracting $asset_file..."
  tar -xzf "$archive_path" -C "$tmp_dir"
  rm -f "$archive_path"

  echo "Installing lazygit..."
  install_dir="$HOME/.local/bin"
  mv "$tmp_dir/lazygit" "$install_dir/lazygit"
  chmod +x "$install_dir/lazygit"
  rm -rf "$tmp_dir"
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
install_lazygit "0.48.0"
# install_zellij
