#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Install Neovim from source
# ---------------------------------------------------------------------------

#######################################
# Check if Neovim is already installed
# Globals:
#   REMOTE_DIR
# Arguments:
#   None
#######################################
function check_installation() {
  local binary="$REMOTE_DIR/nvim-downloads/stable/bin/nvim"

  # Check if already installed
  if [[ -f "$binary" ]] && [[ ! "$FORCE_INSTALL" == "true" ]]; then
    echo "Neovim is already installed."
    exit 0
  fi

}

function create_tmp_dir() {
  local tmp_dir="$REMOTE_DIR/tmp"

  # Create temp directory
  rm -rf "$tmp_dir"
  mkdir -p "$tmp_dir"

}

#######################################
# Show error message and exit
# Globals:
#   None
# Arguments:
#   The error message to display
#######################################
function error_and_exit() {
  echo "$1"
  usage
  exit 1
}

#######################################
# Show the help for this script
# Globals:
#   None
# Arguments:
#   None
#######################################
function help() {
  echo "Install Neovim from source."
  usage
}

#######################################
# Install Neovim from source
# Globals:
#   VERSION
#   REMOTE_DIR
# Arguments:
#   None
#######################################
function install_neovim() {
  local tmp_dir="$REMOTE_DIR/tmp"
  local target="$REMOTE_DIR/nvim-downloads/stable"

  # Install dependencies
  echo "Installing dependencies..."
  sudo apt-get install -y ninja-build gettext cmake unzip curl

  # Download source code
  echo "Downloading source..."
  echo "Version '$VERSION'..."
  git clone "https://github.com/neovim/neovim.git" "$tmp_dir"
  cd "$tmp_dir" && git checkout "$VERSION"

  # Build and install
  echo "Installing Neovim..."
  make CMAKE_BUILD_TYPE=RelWithDebInfo
  sudo make install

  # Copy to target directory
  echo "Copying to target directory..."
  mkdir -p "$target/bin"
  cp -r "/usr/local/bin/nvim" "$target/bin/nvim"

  # Cleanup
  echo "Cleaning up..."
  rm -rf "$tmp_dir"
}

#######################################
# Parse command line arguments
# Globals:
#   VERSION#
#   INSTALL_DIR
#   FORCE_INSTALL
# Arguments:
#   None
#######################################
function parse_arguments() {

  # Set default values
  VERSION="stable"
  REMOTE_DIR="$HOME/tmp"
  FORCE_INSTALL=false

  # Parse command line arguments
  while getopts hv:d:f-: OPT; do
    if [ "$OPT" = "-" ]; then
      OPT="${OPTARG%%=*}"
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      v | version) VERSION="$OPTARG" ;;
      d | dir) REMOTE_DIR="$OPTARG" ;;
      f | force) FORCE_INSTALL="$OPTARG" ;;
      h | help) help && exit ;;
      ??*) error_and_exit "Unknown option --$OPT" ;;
      ?) exit 2 ;;
    esac
  done

}

#######################################
# Show the usage for this script
# Globals:
#   None
# Arguments:
#   None
#######################################
function usage() {
  echo "
  Usage: $0 -v [VERSION] -d [DIR] -f [FORCE]

  Options:
    -v, --version (Optional) The version of Neovim to install. Default: 'stable'
    -d, --dir     (Optional) Directory for storing Neovim source. Default: '$HOME/downloads'
    -f, --force   (Optional) Whether to force installation. Default: false
    -h, --help    Show help information.

  Notes:
    Passing arguments using long option names requires an equals = sign (e.g. --version=[VERSION]).
    An equal sign is not required when using short option names (e.g. -v [VERSION]).
  "
}

#################### Main Program ####################

# Stop script on error
set -euo pipefail

# Parse command line arguments
parse_arguments "$@"

# Check if already installed
if [ ! "$FORCE_INSTALL" = true ]; then
  if command -v nvim &>/dev/null; then
    echo "Neovim is already installed."
    exit 0
  fi
fi

# Install Neovim
install_neovim
