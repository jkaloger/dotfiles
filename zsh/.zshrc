# XDG
export XDG_CONFIG_HOME="/Users/jkaloger/.config"

eval "$(fnm env --use-on-cd --shell zsh)
"# antigen
source ~/.config/zsh/antigen.zsh

antigen bundle zsh-users/zsh-autosuggestions

# antigen done
antigen apply


# pnpm
export PNPM_HOME="/Users/jkaloger/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
#

# bun completions
[ -s "/Users/jkaloger/.bun/_bun" ] && source "/Users/jkaloger/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

[ -f "/Users/jkaloger/.ghcup/env" ] && source "/Users/jkaloger/.ghcup/env" # ghcup-env

export EDITOR="/Users/jkaloger/.nix-profile/bin/nvim"
alias vim="nvim"
alias tml="tmux list-sessions"
alias tma="tmux attach -t"

alias n="pnpm"

alias pr="gh pr list | cut -f1,2 | gum choose | cut -f1 | xargs gh pr view --web"

eval "$(starship init zsh)"

eval "$(zoxide init zsh)"
alias cd="z"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# MOTD
# motd_string="🌈✨🪐👽🌞🚀"
# echo "${motd_string:$(( RANDOM % ${#motd_string} )):2}"
krabby random 1-3 --no-title --no-mega --no-gmax --no-regional

# Puppeteer fix
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH='which chromium'


eval "$(direnv hook zsh)"
eval "$(tv init zsh)"

# Sesh fuzzy finder key binding
function sesh-connect-widget() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -i | gum filter --fuzzy --no-strip-ansi)
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}
zle -N sesh-connect-widget
bindkey '^K' sesh-connect-widget

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.config/zsh/tmux-window-name.zsh
export PATH="$HOME/.local/bin:$PATH"

~/.local/bin/ensure-tmux

# Completion -- must be at the bottom!
export DO_NOT_TRACK=1

