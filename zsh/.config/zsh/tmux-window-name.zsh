# Automatic tmux window naming from package.json
# Renames the tmux window when running pnpm/npm commands in a project.

_TMUX_NODE_ICON="󰎙"

_tmux_pkg_window_name() {
  [[ -z "$TMUX" ]] && return 1
  [[ ! -f "package.json" ]] && return 1

  local pkg_name
  pkg_name=$(jq -r '.name // empty' package.json 2>/dev/null)
  [[ -z "$pkg_name" ]] && return 1

  tmux rename-window "$_TMUX_NODE_ICON $pkg_name"
  tmux set-option -w automatic-rename off
}

_tmux_pkg_window_restore() {
  [[ -z "$TMUX" ]] && return
  tmux set-option -w automatic-rename on
}

# wrap pnpm and npm to rename window for the duration of the command
pnpm() {
  if _tmux_pkg_window_name; then
    command pnpm "$@"
    _tmux_pkg_window_restore
  else
    command pnpm "$@"
  fi
}

npm() {
  if _tmux_pkg_window_name; then
    command npm "$@"
    _tmux_pkg_window_restore
  else
    command npm "$@"
  fi
}
