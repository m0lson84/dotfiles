#    __                  _   _
#   / _|                | | (_)
#  | |_ _   _ _ __   ___| |_ _  ___  _ __  ___
#  |  _| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#  | | | |_| | | | | (__| |_| | (_) | | | \__ \
#  |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#
#

#######################################
# Update all apt packages
#######################################
function apt_update() {
  echo "Updating apt packages..."
  sudo apt update && sudo apt upgrade -y
  echo "Running cleaning up tasks..."
  sudo apt autoremove -y && sudo apt autoclean
}

#######################################
# Update Homebrew formulas/casks
#######################################
function brew_update() {
  echo "Updating homebrew formulas/casks..."
  brew update && brew outdated
  brew upgrade
  echo "Running cleaning up tasks..."
  brew autoremove && brew cleanup
}

#######################################
# Execute a function using the devcontainer CLI
# Arguments:
#   The operation to execute.
#######################################
function devcontainer_cli() {
  local args=$1
  case $1 in
    "up") _devcontainer_up ;;
    "exec") _devcontainer_exec $2 ;;
    *) echo "Invalid operation: $1" ;;
  esac
}

#######################################
# Fix for OBS virtual camera in Slack
#######################################
fix_obs_virtual_cam_in_slack() {
  echo "Applying virtual camera fix for Slack..."
  sudo codesign --remove-signature "/Applications/Slack.app/"
  sudo codesign --remove-signature "/Applications/Slack.app/Contents/Frameworks/Slack Helper (Renderer).app"
  sudo codesign --remove-signature "/Applications/Slack.app/Contents/Frameworks/Slack Helper (GPU).app"
  sudo codesign --remove-signature "/Applications/Slack.app/Contents/Frameworks/Slack Helper (Plugin).app"
}

#######################################
# Update all yay packages
#######################################
yay_update() {
  echo "Updating yay packages..."
  yay -Syu
  echo "Running cleaning up tasks..."
  yay -Yc
}

#######################################
# Create and run a devcontainer
# Arguments:
#   The command to execute in the container.
#######################################
function _devcontainer_exec() {
  echo "Executing command in development container..."
  devcontainer exec --workspace-folder . $1
}

#######################################
# Create and run a devcontainer
#######################################
function _devcontainer_up() {
  echo "Building and running development container..."

  dotfiles="https://github.com/m0lson84/dotfiles.git"
  remote_env="REMOTE_CONTAINERS=true"
  additional_features=$(jq -n -c \
    '{
      "ghcr.io/devcontainers-extra/features/starship:1": {},
      "ghcr.io/duduribeiro/devcontainer-features/neovim:1": { "version": "nightly" }
    }')

  devcontainer up \
    --workspace-folder . \
    --remote-env "$remote_env" \
    --additional-features "$additional_features" \
    --dotfiles-repository "$dotfiles" \
    --include-merged-configuration

}
