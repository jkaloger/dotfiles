#!/usr/bin/env bash
set -euo pipefail

WORKTREE_ROOT="$HOME/worktrees"
LOG_FILE="${TMPDIR:-/tmp}/new-worktree.log"

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$LOG_FILE"; }

C_ACCENT="#9ece6a"
C_DIM="8"
C_ERR="#f7768e"
C_OK="#9ece6a"

export GUM_CHOOSE_PADDING="0 2"
export GUM_INPUT_PADDING="0 2"
export GUM_FILTER_PADDING="0 2"
export GUM_SPIN_PADDING="0 2"

log "--- new run ---"

if ! git rev-parse --show-toplevel &>/dev/null; then
  gum style --foreground="$C_ERR" "❌ Not in a git repository"
  sleep 1
  exit 1
fi

# Always resolve to the original clone, not a worktree
repo_root=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
project=$(basename "$repo_root")
log "repo_root=$repo_root project=$project"

echo ""
gum style --foreground="$C_ACCENT" --bold --border=rounded --border-foreground="$C_ACCENT" --padding="0 2" \
  "🌲 New Worktree :: $project"
echo ""

mode=$(gum choose "New branch" "Existing branch")
[ -z "$mode" ] && exit 0

# Branches with main/master first, ordered by last commit date
branches=$(git branch -a --format='%(committerdate:iso8601)	%(refname:short)' | sed 's|	origin/|	|' | sort -t'	' -k2 -u | sort -t'	' -k1,1r | cut -f2 | grep -v '^HEAD$')
main_branch=$(echo "$branches" | grep -E '^(main|master)$' | head -1)
other_branches=$(echo "$branches" | grep -vE '^(main|master)$')
ordered_branches=$(printf '%s\n%s' "$main_branch" "$other_branches")

if [ "$mode" = "New branch" ]; then
  name=$(gum input \
    --placeholder="worktree name" \
    --width=40)
  [ -z "$name" ] && exit 0

  base=$(echo "$ordered_branches" | gum filter \
    --fuzzy \
    --placeholder="base" \
    --height=10 \
    --no-strip-ansi)
  [ -z "$base" ] && exit 0

  wt_mode="new"
  log "mode=new name=$name base=$base"
else
  branch=$(echo "$ordered_branches" | gum filter \
    --fuzzy \
    --placeholder="branch" \
    --height=10 \
    --no-strip-ansi)
  [ -z "$branch" ] && exit 0

  name=$(echo "$branch" | sed 's|/|-|g')
  base="$branch"
  wt_mode="existing"
  log "mode=existing name=$name base=$base branch=$branch"
fi

worktree_dir="$WORKTREE_ROOT/$project/$name"
log "worktree_dir=$worktree_dir wt_mode=$wt_mode"

if [ -d "$worktree_dir" ]; then
  echo ""
  gum style --foreground="$C_DIM" "🔗 Worktree exists, reconnecting..."
  sesh connect "$project/$name"
  exit 0
fi

echo ""

setup_worktree() {
  local repo="$1" dest="$2" wt_name="$3" wt_base="$4" wt_mode="$5"
  local _log_file="${TMPDIR:-/tmp}/new-worktree.log"
  local _err_file="${TMPDIR:-/tmp}/new-worktree-err.txt"
  _log() { printf '[%s] [setup] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$_log_file"; }

  _log "repo=$repo dest=$dest wt_name=$wt_name wt_base=$wt_base wt_mode=$wt_mode"

  if [ "$wt_mode" = "new" ]; then
    _log "git worktree add -b $wt_name $dest $wt_base"
    if ! git worktree add -b "$wt_name" "$dest" "$wt_base" 2>"$_err_file"; then
      _log "git worktree add failed (new branch): $(cat "$_err_file")"
      return 1
    fi
  else
    if git show-ref --verify --quiet "refs/heads/$wt_base"; then
      _log "local branch found, git worktree add $dest $wt_base"
      if ! git worktree add "$dest" "$wt_base" 2>"$_err_file"; then
        _log "git worktree add failed (local branch): $(cat "$_err_file")"
        return 1
      fi
    else
      _log "remote-only branch, git worktree add -b $wt_base $dest origin/$wt_base"
      if ! git worktree add -b "$wt_base" "$dest" "origin/$wt_base" 2>"$_err_file"; then
        _log "git worktree add failed (remote branch): $(cat "$_err_file")"
        return 1
      fi
    fi
  fi
  _log "git worktree add succeeded"

  (cd "$repo" && find . -name '.env*' \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/.claude/*') | while read -r f; do
    mkdir -p "$dest/$(dirname "$f")"
    cp "$repo/$f" "$dest/$f"
  done

  if [ -d "$repo/.claude" ]; then
    mkdir -p "$dest/.claude"
    (cd "$repo/.claude" && find . -name 'settings*' -type f) | while read -r f; do
      cp "$repo/.claude/$f" "$dest/.claude/$f"
    done
  fi

  if [ -f "$dest/pnpm-lock.yaml" ]; then
    (cd "$dest" && pnpm install --frozen-lockfile --prefer-offline 2>/dev/null) || true
  elif [ -f "$dest/package-lock.json" ]; then
    (cd "$dest" && npm ci --prefer-offline 2>/dev/null) || true
  fi
}

if ! gum spin --spinner minidot --title "Setting up $name from $base..." -- \
  bash -c "$(declare -f setup_worktree); setup_worktree \"\$1\" \"\$2\" \"\$3\" \"\$4\" \"\$5\"" _ "$repo_root" "$worktree_dir" "$name" "$base" "$wt_mode"; then
  err_detail=""
  [ -f "${TMPDIR:-/tmp}/new-worktree-err.txt" ] && err_detail=$(cat "${TMPDIR:-/tmp}/new-worktree-err.txt")
  log "setup failed: $err_detail"
  gum style --foreground="$C_ERR" "❌ Failed to create worktree"
  [ -n "$err_detail" ] && gum style --foreground="$C_DIM" "$err_detail"
  gum style --foreground="$C_DIM" "log: $LOG_FILE"
  exit 1
fi

log "creating tmux session: $project/$name at $worktree_dir"
tmux new-session -d -s "$project/$name" -c "$worktree_dir"

log "connecting via sesh"
sesh connect "$project/$name"
