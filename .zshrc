# antigen
source ~/.antigen.zsh
antigen use oh-my-zsh
antigen theme robbyrussell
antigen apply
# antigen end

# zoxide
eval "$(zoxide init zsh)"
# zoxide end

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# nvm end

# pnpm
export PNPM_HOME="~/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# aliases
alias vim="nvim"
alias cd="z"
alias fzf="fzf --preview 'cat {}' "
# aliases end

# opam configuration
[[ ! -r /Users/jack/.opam/opam-init/init.zsh ]] || source /Users/jack/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
# opam end

# bun
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
# bun end

# fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
# fzf end

# MOTD
motd_string="🌈✨🪐👽🌞🚀"
echo "${motd_string:$(( RANDOM % ${#motd_string} )):2}"
krabby random 1-3 --no-title -i --no-mega --no-gmax --no-regional
export pokemon=krabby
# MOTD end
