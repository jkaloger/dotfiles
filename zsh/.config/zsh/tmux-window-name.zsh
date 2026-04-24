# Automatic tmux window naming from package.json
# Renames the tmux window when running pnpm/npm commands in a project.

tmux_pkg_window_name() {
  [[ -z "$TMUX" ]] && return 1
  [[ ! -f "package.json" ]] && return 1

  local pkg_name
  pkg_name=$(jq -r '.name // empty' package.json 2>/dev/null)
  [[ -z "$pkg_name" ]] && return 1

  tmux rename-window "󰎙 $pkg_name"
  tmux set-option -w automatic-rename off
}

tmux_pkg_window_restore() {
  [[ -z "$TMUX" ]] && return
  tmux set-option -w automatic-rename on
}

pnpm() {
  if tmux_pkg_window_name; then
    command pnpm "$@"
    tmux_pkg_window_restore
  else
    command pnpm "$@"
  fi
}

npm() {
  if tmux_pkg_window_name; then
    command npm "$@"
    tmux_pkg_window_restore
  else
    command npm "$@"
  fi
}
