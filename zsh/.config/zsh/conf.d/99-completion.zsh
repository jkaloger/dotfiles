[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# antigen's cached init stubs compdef to a no-op until its own precmd hook runs
# compinit, so anything calling compdef at startup is silently dropped.
_deferred_completions() {
  source <(lazyspec completions zsh)
  source <(COMPLETE=zsh hydra)
  add-zsh-hook -D precmd _deferred_completions
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _deferred_completions
