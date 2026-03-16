#!/usr/bin/env bash
set -euo pipefail

WORKTREE_ROOT="$HOME/worktrees"

C_ACCENT="4"
C_DIM="8"
C_ERR="1"
C_OK="2"

if ! git rev-parse --show-toplevel &>/dev/null; then
  gum style --foreground="$C_ERR" "❌ Not in a git repository"
  sleep 1
  exit 1
fi

# Always resolve to the original clone, not a worktree
repo_root=$(git worktree list --porcelain | head -1 | sed 's/^worktree //')
project=$(basename "$repo_root")

echo ""
gum style --foreground="$C_ACCENT" --bold --border=rounded --border-foreground="$C_ACCENT" --padding="0 2" \
  "🌲 New Worktree :: $project"
echo ""

mode=$(gum choose "New branch" "Existing branch")
[ -z "$mode" ] && exit 0

# Branches with main/master first
branches=$(git branch -a --format='%(refname:short)' | sed 's|^origin/||' | sort -u | grep -v '^HEAD$')
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
fi

worktree_dir="$WORKTREE_ROOT/$project/$name"

if [ -d "$worktree_dir" ]; then
  echo ""
  gum style --foreground="$C_DIM" "🔗 Worktree exists, reconnecting..."
  sesh connect "$project/$name"
  exit 0
fi

echo ""

setup_worktree() {
  local repo="$1" dest="$2" wt_name="$3" wt_base="$4" wt_mode="$5"

  if [ "$wt_mode" = "new" ]; then
    git worktree add -b "$wt_name" "$dest" "$wt_base" 2>/dev/null
  else
    git worktree add "$dest" "$wt_base" 2>/dev/null
  fi

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

export -f setup_worktree
gum spin --spinner minidot --title "Setting up $name from $base..." -- \
  bash -c "$(declare -f setup_worktree); setup_worktree \"\$1\" \"\$2\" \"\$3\" \"\$4\" \"\$5\"" _ "$repo_root" "$worktree_dir" "$name" "$base" "$wt_mode"

tmux new-session -d -s "$project/$name" -c "$worktree_dir"

sesh connect "$project/$name"
