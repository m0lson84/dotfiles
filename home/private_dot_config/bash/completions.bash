#                             _      _   _
#                            | |    | | (_)
#    ___ ___  _ __ ___  _ __ | | ___| |_ _  ___  _ __  ___
#   / __/ _ \| '_ ` _ \| '_ \| |/ _ \ __| |/ _ \| '_ \/ __|
#  | (_| (_) | | | | | | |_) | |  __/ |_| | (_) | | | \__ \
#   \___\___/|_| |_| |_| .__/|_|\___|\__|_|\___/|_| |_|___/
#                      | |
#                      |_|

# 1Password CLI
if command -v op >/dev/null; then
  source <(op completion bash)
fi

# Bob (Neovim version manager)
if command -v bob >/dev/null; then
  source <(bob complete bash)
fi

# DevPod
if command -v devpod >/dev/null; then
  source <(devpod complete bash)
fi

# Kubernetes
if command -v kubectl >/dev/null; then
  source <(kubectl completion bash)
fi

# Starship initialization
if command -v starship >/dev/null; then
  source <(starship completions bash)
fi
