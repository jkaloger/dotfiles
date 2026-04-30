alias vim="nvim"
alias tml="tmux list-sessions"
alias tma="tmux attach -t"
alias n="pnpm"
alias pr="gh pr list | cut -f1,2 | gum choose | cut -f1 | xargs gh pr view --web"
alias cd="z"

nxu() { (cd "$HOME/dotfiles/nix" && nix --extra-experimental-features 'nix-command flakes' flake update "$@") }
nxs() { (cd "$HOME/dotfiles/nix" && ./scripts/aarch64-darwin/build-switch.sh "$@") }
