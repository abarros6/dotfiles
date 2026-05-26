# dotfiles

Personal dotfiles for keeping tool configuration in version control and in sync across machines. Config files live here and are symlinked into the right places on each machine, so changes can be tracked in git and shared anywhere.

## What's included

| Path in repo | Symlinked to |
|---|---|
| `claude/settings.json` | `~/.claude/settings.json` |
| `claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |

## Setup on a new machine

1. Clone the repo somewhere convenient:
   ```bash
   git clone <your-remote-url>
   ```

2. Run the install script from inside the repo:
   ```bash
   bash install.sh
   ```

`install.sh` will create any missing config directories, back up existing files that aren't already symlinks, and symlink everything into place.
