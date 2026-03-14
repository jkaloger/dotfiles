#!/usr/bin/env bash
set -euo pipefail

WORKTREE_ROOT="$HOME/worktrees"

C_ACCENT="4"
C_DIM="8"
C_ERR="1"
C_OK="2"

repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$repo_root" ]; then
  gum style --foreground="$C_ERR" "❌ Not in a git repository"
  sleep 1
  exit 1
fi

project=$(basename "$repo_root")

echo ""
gum style --foreground="$C_ACCENT" --bold --border=rounded --border-foreground="$C_ACCENT" --padding="0 2" \
  "🌲 New Worktree :: $project"
echo ""

name=$(gum input \
  --placeholder="worktree name" \
  --width=40)
[ -z "$name" ] && exit 0

# Branches with main/master first
branches=$(git branch -a --format='%(refname:short)' | sed 's|^origin/||' | sort -u | grep -v '^HEAD$')
main_branch=$(echo "$branches" | grep -E '^(main|master)$' | head -1)
other_branches=$(echo "$branches" | grep -vE '^(main|master)$')
ordered_branches=$(printf '%s\n%s' "$main_branch" "$other_branches")

base=$(echo "$ordered_branches" | gum filter \
  --fuzzy \
  --placeholder="base" \
  --height=10 \
  --no-strip-ansi)
[ -z "$base" ] && exit 0

worktree_dir="$WORKTREE_ROOT/$project/$name"

if [ -d "$worktree_dir" ]; then
  echo ""
  gum style --foreground="$C_DIM" "🔗 Worktree exists, reconnecting..."
  sesh connect "$project/$name"
  exit 0
fi

echo ""

setup_worktree() {
  local repo="$1" dest="$2" wt_name="$3" wt_base="$4"

  git worktree add -b "$wt_name" "$dest" "$wt_base" 2>/dev/null

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

  (cd "$repo" && find . -name 'node_modules' -maxdepth 3 \
    -not -path '*/node_modules/*/node_modules') | while read -r d; do
    local target="$dest/$d"
    mkdir -p "$(dirname "$target")"
    ln -sf "$(cd "$repo" && realpath "$d")" "$target"
  done
}

export -f setup_worktree
gum spin --spinner minidot --title "Setting up $name from $base..." -- \
  bash -c "$(declare -f setup_worktree); setup_worktree '$repo_root' '$worktree_dir' '$name' '$base'"

tmux new-session -d -s "$project/$name" -c "$worktree_dir"

sesh connect "$project/$name"

