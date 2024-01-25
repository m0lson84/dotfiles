#                             _      _   _
#                            | |    | | (_)
#    ___ ___  _ __ ___  _ __ | | ___| |_ _  ___  _ __  ___
#   / __/ _ \| '_ ` _ \| '_ \| |/ _ \ __| |/ _ \| '_ \/ __|
#  | (_| (_) | | | | | | |_) | |  __/ |_| | (_) | | | \__ \
#   \___\___/|_| |_| |_| .__/|_|\___|\__|_|\___/|_| |_|___/
#                      | |
#                      |_|

zstyle ':autocomplete:*' default-context ''
zstyle ':autocomplete:*' min-delay 0.25
zstyle ':autocomplete:*' min-input 3
zstyle ':autocomplete:*' list-lines 5
zstyle ':autocomplete:history-incremental-search-*:*' list-lines 10
zstyle ':autocomplete:*' fzf-completion yes
zstyle ':autocomplete:*' widget-style menu-complete

# 1Password CLI
if command -v op >/dev/null; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# Bob (Neovim version manager)
if command -v bob >/dev/null; then
  source <(bob complete zsh)
fi

# DevPod
if command -v devpod >/dev/null; then
  eval "$(devpod completion zsh)"
  compdef _devpod devpod
fi

# Fast Node Manager (fnm)
if command -v fnm >/dev/null; then
  eval $(fnm completions --shell zsh)
fi

# Kubernetes
if command -v kubectl >/dev/null; then
  source <(kubectl completion zsh)
fi

# Starship initialization
if command -v starship >/dev/null; then
  eval "$(starship completions zsh)"
fi
