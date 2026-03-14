function sesh-connect-widget() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -i | gum filter --fuzzy --no-strip-ansi)
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect "$session"
  }
}
zle -N sesh-connect-widget
bindkey '^K' sesh-connect-widget
