# tmux-dangerclaude-config

Personal dotfiles for a multi-device tmux + Claude Code workflow. Desktop is the persistence anchor; laptop and phone (Termux) attach via SSH over Tailscale. Sessions outlive every network drop.

**Resilient by design**: `install.sh` copies files into your home directory — not symlinks. Delete this repo and everything still works. The repo is just the versioned source, not a runtime dependency.

## What's in here

| File | Purpose |
|------|---------|
| `tmux.conf` | Full tmux config: Ctrl+Space prefix, true-color, 50k scrollback, top status bar, mouse on, aggressive-resize, TPM plugins (resurrect, continuum, yank, sensible). |
| `tmux-cheatsheet.txt` | 172-line reference for every keybinding, shell helper, and workflow tip. Run `tcheat` to view it from any terminal. |
| `bashrc.d/10-dangerclaude.sh` | `_dangerclaude` wrapper function + 8 Terminator-themed aliases. |
| `bashrc.d/20-tmux-helpers.sh` | `t` / `tl` / `tk` / `ts` / `tcheat` shell helpers and SSH auto-attach. |
| `bashrc.d/30-dsync.sh` | `dsync` function — syncs home config edits back into this repo. |
| `install.sh` | Idempotent setup script — copies files, bashrc injection, TPM clone. |

## Install on a new machine

```bash
git clone git@github.com:MartyBonacci/tmux-dangerclaude-config.git ~/code-projects/tmux-dangerclaude-config
~/code-projects/tmux-dangerclaude-config/install.sh
source ~/.bashrc
```

Then inside tmux: press `Ctrl+Space` then `Shift+I` to install plugins via TPM.

## How it works

- **Copies, not symlinks**: `install.sh` copies `tmux.conf` → `~/.tmux.conf`, `bashrc.d/*.sh` → `~/.bashrc.d/`, etc. These are real files. Delete this repo and everything keeps running.
- **Modular bashrc**: Your `~/.bashrc` gets a small sourcing loop appended that reads `~/.bashrc.d/*.sh` at every shell start. The rest of `~/.bashrc` is untouched.
- **`~/.dotfiles` symlink**: Optional convenience — just makes `cd ~/.dotfiles` work for git operations. Nothing depends on it.

## The `_dangerclaude` aliases

All 8 run: `claude --dangerously-skip-permissions --continue --name $DIR --remote-control` with `DISABLE_COMPACT=1`:

| Alias | Reference |
|---|---|
| `214am` | Skynet became self-aware at 2:14 AM Eastern, Aug 29 1997 |
| `skynet` | The rogue AI itself |
| `t800` | Arnold's Cyberdyne Systems Model 101 |
| `t1000` | The liquid-metal T2 villain |
| `terminate` | Deadpan menace |
| `trustmebro` | Famous last words |
| `claudenator` | Claude + Terminator portmanteau |
| `whatcouldgowrong` | Ironic dread-comedy |

## Daily workflow

- **Desktop (at home)**: `t` → lands in `main` tmux → `skynet` → Claude Code.
- **Laptop (SSH + Tailscale)**: `ssh desktop` → auto-attached to `main`.
- **Phone (Termux + Tailscale)**: `ssh desktop` → auto-attached to `main`.

Your tmux session never dies on the desktop. Switch devices freely.

## Editing and syncing configs

Edit any installed file normally:

```bash
nano ~/.tmux.conf       # edit the real installed copy
```

Then sync your edits back into the repo:

```bash
dsync                   # copies changed files from ~ back into the repo
cd ~/.dotfiles          # follow convenience symlink to repo
git diff                # review what changed
git add -A && git commit -m "tweak: status bar colors"
git push
```

On the other machine, pull and re-install:

```bash
cd ~/.dotfiles && git pull
./install.sh            # refreshes copies from repo (always safe to re-run)
source ~/.bashrc        # for bashrc.d changes
# inside tmux: Ctrl+Space + r   for tmux.conf changes
```

## What survives what

| Scenario | Effect |
|---|---|
| Delete this repo | All configs keep working. `dsync` warns but nothing breaks. Re-clone to resume syncing. |
| Delete `~/.dotfiles` symlink | Configs still work. `dsync` falls back to checking `~/code-projects/tmux-dangerclaude-config/`. |
| Delete `~/.bashrc.d/` | Functions/aliases vanish from new shells. Re-run `install.sh` to restore. |
| Delete `~/.tmux.conf` | Tmux falls back to defaults. Re-run `install.sh` to restore. |

## Prerequisites

- `claude` binary on `$PATH` (Claude Code) — required for the `_dangerclaude` aliases
- `tmux` 3.0 or later
- `git` — for TPM plugin cloning
- Tailscale — optional, but it's how the multi-device workflow reaches the desktop

## Termux note

On Termux, Ctrl+Space doesn't work natively from the soft keyboard. Add a macro button to `~/.termux/termux.properties`:

```properties
extra-keys = [ \
  [{macro: "CTRL SPACE", display: "prefix"}, 'ESC', '/', '-', 'HOME', 'UP', 'END', 'PGUP'], \
  ['TAB', 'CTRL', 'ALT', 'LEFT', 'DOWN', 'RIGHT', 'PGDN'] \
]
```

Then `termux-reload-settings`. If the keyboard disappears after switching sessions, swipe from the left edge and tap KEYBOARD.
