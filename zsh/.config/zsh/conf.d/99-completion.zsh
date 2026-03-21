[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

_lazyspec_compinit() {
  source <(lazyspec completions zsh)
  add-zsh-hook -D precmd _lazyspec_compinit
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _lazyspec_compinit
