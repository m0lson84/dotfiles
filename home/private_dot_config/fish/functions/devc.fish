#######################################
# Execute a function using the devcontainer CLI
# Arguments:
#   The operation to execute.
#######################################
function devc
    set op $argv[1]
    switch $op
        case build
            _devcontainer_build $argv[2..-1]
        case up
            _devcontainer_up $argv[2..-1]
        case exec
            _devcontainer_exec $argv[2..-1]
        case session
            _devcontainer_session $argv[2..-1]
        case '*'
            gum log --level error "Invalid operation: $op"
    end
end

#######################################
# Build a devcontainer image
#######################################
function _devcontainer_build
    gum log --level info "Building development container image..."

    set remote_env "REMOTE_CONTAINERS=true"

    devcontainer build \
        --workspace-folder . \
        --remote-env "$remote_env" \
        $argv

end

#######################################
# Create and run a devcontainer
# Arguments:
#   The command to execute in the container.
#######################################
function _devcontainer_exec
    gum log --level info "Executing command in development container..."

    set remote_env "REMOTE_CONTAINERS=true"

    devcontainer exec \
        --workspace-folder . \
        --remote-env "$remote_env" \
        $argv

end

#######################################
# Open a Zellij session using the devcontainer layout
# Arguments:
#   Optional session name.
#######################################
function _devcontainer_session
    if not devcontainer exec --workspace-folder . true >/dev/null 2>&1
        _devcontainer_up
    end

    gum log --level info "Starting development container session..."

    if not devcontainer exec --workspace-folder . true >/dev/null 2>&1
        gum log --level error "Failed to start session. Please ensure container is running."
    end

    set options
    if test (count $argv) -gt 0
        set options --session-name $argv[1]
    end

    zellij options --default-layout devcontainer $options
end

#######################################
# Create and run a devcontainer
#######################################
function _devcontainer_up
    gum log --level info "Building and running development container..."

    set dotfiles "https://github.com/m0lson84/dotfiles.git"
    set remote_env "REMOTE_CONTAINERS=true"
    set additional_features (jq -n -c '
    {
      "ghcr.io/devcontainers-extra/features/starship:1": {}
    }'
  )

    devcontainer up \
        --workspace-folder . \
        --remote-env "$remote_env" \
        --additional-features "$additional_features" \
        --dotfiles-repository "$dotfiles" \
        $argv

end
