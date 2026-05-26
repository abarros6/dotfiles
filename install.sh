#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.claude"

link() {
  local src="$DOTFILES_DIR/$1"
  local dest="$HOME/$2"

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "Backing up existing $dest -> ${dest}.bak"
    mv "$dest" "${dest}.bak"
  fi

  ln -sf "$src" "$dest"
  echo "Linked $dest -> $src"
}

link "claude/settings.json" ".claude/settings.json"
link "claude/statusline-command.sh" ".claude/statusline-command.sh"

echo "Done."
