#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

packages=(
  zsh
  tmux
  ghostty
  gh-dash
  nvim
  git
  lazygit
  aerospace
  sketchybar
  btop
  claude
  hypr
  waybar
  fuzzel
)

echo "🏠 Stowing dotfiles from $DOTFILES_DIR"

for pkg in "${packages[@]}"; do
  if [ -d "$DOTFILES_DIR/$pkg" ]; then
    echo "  → $pkg"
    stow -d "$DOTFILES_DIR" -t "$HOME" --restow "$pkg"
  fi
done

echo "✅ Done"
