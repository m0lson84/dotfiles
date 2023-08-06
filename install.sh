#!/usr/bin/env bash

# =============================================================================
# Install and configure system
# =============================================================================

#######################################
# Install chezmoi if it doesn't exist
# Globals:
#   HOME
# Arguments:
#   None
# Outputs:
#   Writes install location to stdout
#######################################
function install_chezmoi {
  local bin_dir="${HOME}/.local/bin"
  local chezmoi install_script

  # Check if chezmoi is already installed
  if chezmoi="$(command -v chezmoi)"; then
    echo "$chezmoi"
    return
  fi

  chezmoi="${bin_dir}/chezmoi"

  # Get install script
  if command -v curl >/dev/null; then
    install_script="$(curl -fsSL https://chezmoi.io/get)"
  elif command -v wget >/dev/null; then
    install_script="$(wget -qO- https://chezmoi.io/get)"
  else
    echo "To install chezmoi, you must have curl or wget installed." >&2
    exit 1
  fi

  sh -c "${install_script}" -- -b "${bin_dir}"

  echo "$chezmoi"
}

#################### Main Program ####################

# -e: exit on error
# -u: exit on unset variables
set -eu

# Get chezmoi
chezmoi="$(install_chezmoi)"

# POSIX way to get script's dir: https://stackoverflow.com/a/29834779/12156188
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

set -- init --apply --source="${script_dir}"

# Replace current process with chezmoi
echo "Running 'chezmoi $*'" >&2
exec "$chezmoi" "$@"
