#######################################
# Execute a function using the devcontainer CLI
# Arguments:
#   The operation to execute.
#######################################
function devc
    set op $argv[1]
    switch $op
        case up
            _devcontainer_up
        case exec
            _devcontainer_exec $argv[2]
        case '*'
            echo "Invalid operation: $op"
    end
end

#######################################
# Create and run a devcontainer
# Arguments:
#   The command to execute in the container.
#######################################
function _devcontainer_exec
    echo "Executing command in development container..."
    devcontainer exec --workspace-folder . $argv[1]
end

#######################################
# Create and run a devcontainer
#######################################
function _devcontainer_up
    echo "Building and running development container..."

    set dotfiles "https://github.com/m0lson84/dotfiles.git"
    set remote_env "REMOTE_CONTAINERS=true"
    set additional_features (jq -n -c '
    {
      "ghcr.io/devcontainers-extra/features/starship:1": {},
      "ghcr.io/duduribeiro/devcontainer-features/neovim:1": { "version": "nightly" }
    }'
  )

    devcontainer up \
        --workspace-folder . \
        --remote-env "$remote_env" \
        --additional-features "$additional_features" \
        --dotfiles-repository "$dotfiles" \
        --include-merged-configuration

end
