# dotfiles

Personal dotfiles for syncing tool configuration across machines.

## What's included

| Path in repo | Symlinked to |
|---|---|
| `claude/settings.json` | `~/.claude/settings.json` |

## Setup on a new machine

1. Clone the repo:
   ```bash
   git clone <your-remote-url> ~/projects/dotfiles
   ```

2. Run the install script:
   ```bash
   cd ~/projects/dotfiles
   bash install.sh
   ```

`install.sh` will create `~/.claude/` if it doesn't exist, back up any existing files that aren't already symlinks, and symlink everything into place.
