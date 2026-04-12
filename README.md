# tmux-dangerclaude-config

Personal dotfiles for a multi-device tmux + Claude Code workflow. Desktop is the persistence anchor; laptop and phone (Termux) attach via SSH over Tailscale. Sessions outlive every network drop.

## What's in here

| File | Purpose |
|------|---------|
| `tmux.conf` | Full tmux config: Ctrl+Space prefix, true-color, 50k scrollback, top status bar, mouse on, aggressive-resize, TPM plugins (resurrect, continuum, yank, sensible). |
| `tmux-cheatsheet.txt` | 172-line reference for every keybinding, shell helper, and workflow tip. Run `tcheat` to view it from any terminal. |
| `bashrc.d/10-dangerclaude.sh` | `_dangerclaude` wrapper function + 8 Terminator-themed aliases. |
| `bashrc.d/20-tmux-helpers.sh` | `t` / `tl` / `tk` / `ts` / `tcheat` shell helpers and SSH auto-attach. |
| `install.sh` | Idempotent setup script — symlinks, bashrc injection, TPM clone. |

## Install on a new machine

```bash
git clone git@github.com:MartyBonacci/tmux-dangerclaude-config.git ~/code-projects/tmux-dangerclaude-config
~/code-projects/tmux-dangerclaude-config/install.sh
source ~/.bashrc
```

Then inside tmux: press `Ctrl+Space` then `Shift+I` to install plugins via TPM.

## How it works

- **Symlinks, not copies**: `~/.tmux.conf`, `~/.tmux-cheatsheet.txt`, and `~/.dotfiles` are all symlinks into this repo. Edit any of them normally and `git status` sees the change.
- **Modular bashrc**: Your `~/.bashrc` gets a small sourcing loop appended that reads `~/.dotfiles/bashrc.d/*.sh` at every shell start. The rest of `~/.bashrc` is untouched, so machine-specific PATH/fnm/etc. stays local.
- **Path-independent**: `~/.dotfiles` is a symlink to this repo's actual location. Each machine can clone to a different path; the sourcing loop is identical everywhere.

## The `_dangerclaude` aliases

All 8 of these run the same command — a fully-loaded Claude Code launch with `--dangerously-skip-permissions`, `--continue`, `--name $(basename $PWD)`, `--remote-control`, and `DISABLE_COMPACT=1`:

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

## Updating

Edit any tracked file normally — the symlinks make this transparent:

```bash
nano ~/.tmux.conf               # edit the real file (via symlink)
cd ~/.dotfiles                  # follow symlink to the repo
git diff                        # see what changed
git add -A && git commit -m "tweak: status bar colors"
git push
```

On the other machine:

```bash
cd ~/.dotfiles && git pull
# if install.sh itself changed, re-run it
./install.sh
```

Re-running `install.sh` is always safe — it's idempotent.

## Prerequisites

- `claude` binary on `$PATH` (Claude Code) — required for the `_dangerclaude` aliases
- `tmux` 3.0 or later
- `git` — for TPM plugin cloning
- Tailscale — optional, but it's how the multi-device workflow reaches the desktop from anywhere

## Termux note

On Termux, Ctrl+Space from the soft keyboard doesn't work natively. Add a macro button to `~/.termux/termux.properties`:

```properties
extra-keys = [ \
  [{macro: "CTRL SPACE", display: "prefix"}, 'ESC', '/', '-', 'HOME', 'UP', 'END', 'PGUP'], \
  ['TAB', 'CTRL', 'ALT', 'LEFT', 'DOWN', 'RIGHT', 'PGDN'] \
]
```

Then `termux-reload-settings`. A "prefix" button will appear — tap it to send Ctrl+Space to tmux. If the soft keyboard disappears after session switching, swipe from the left edge and tap the KEYBOARD button to bring it back.
