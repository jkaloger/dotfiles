path_prepend() { [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH" }

export PNPM_HOME="$HOME/Library/pnpm"
path_prepend "$PNPM_HOME"

export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"

path_prepend "$HOME/.local/bin"
