# tmux-dangerclaude-config

> ⚠️ **Read this before installing.**
>
> The nine `_dangerclaude` aliases in this repo (`skynet`, `t800`, `t1000`, `214am`, `terminate`, `trustmebro`, `claudenator`, `whatcouldgowrong`, `itcouldonlygoodhappen`) launch Claude Code with `--dangerously-skip-permissions`, which removes **all** per-action confirmation prompts. Once invoked, Claude can read, write, execute, and delete anything your user account can — without asking. Files Claude reads can also prompt-inject it into doing things you didn't ask for.
>
> Use only on a personal machine, in directories you trust, with no production credentials in your shell environment. **The Terminator names are a deliberate warning, not branding.** If any of this surprises you, do not run `skynet`. See [Security notes](#security-notes) below for a flag-by-flag breakdown.

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
git clone https://github.com/MartyBonacci/tmux-dangerclaude-config.git ~/code-projects/tmux-dangerclaude-config
~/code-projects/tmux-dangerclaude-config/install.sh
source ~/.bashrc
```

The installer previews the lines it wants to append to `~/.bashrc` and prompts for confirmation. Then inside tmux: press `Ctrl+Space` then `Shift+I` to install plugins via TPM.

### Install options

| Variable | Default | Purpose |
|---|---|---|
| `INSTALL_YES=1` | unset | Skip the `~/.bashrc` confirmation prompt (for non-interactive installs) |
| `TPM_REF=<ref>` | `v3.1.0` | TPM tag/branch to clone — pinned to a known release for supply-chain safety |
| `TMUX_AUTO_ATTACH=0` | unset (=1) | Export in your shell profile to disable the SSH auto-attach into the `main` tmux session |

## How it works

- **Copies, not symlinks**: `install.sh` copies `tmux.conf` → `~/.tmux.conf`, `bashrc.d/*.sh` → `~/.bashrc.d/`, etc. These are real files. Delete this repo and everything keeps running.
- **Modular bashrc**: Your `~/.bashrc` gets a small sourcing loop appended that reads `~/.bashrc.d/*.sh` at every shell start. The rest of `~/.bashrc` is untouched.
- **`~/.dotfiles` symlink**: Optional convenience — just makes `cd ~/.dotfiles` work for git operations. Nothing depends on it.

## The `_dangerclaude` aliases

All 9 run: `claude --dangerously-skip-permissions --continue --name $DIR --remote-control` with `DISABLE_COMPACT=1`:

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
| `itcouldonlygoodhappen` | Mangled-grammar optimism (inverse of `whatcouldgowrong`) |

## Security notes

These aliases trade safety for speed. Here's what each flag actually does, so you can decide whether to install them:

| Flag / env | What it does | Risk |
|---|---|---|
| `--dangerously-skip-permissions` | Removes Claude's per-action approval prompts for tool use | Claude can run any shell command, edit any file, delete anything your user can. Files Claude reads can prompt-inject and hijack behavior. |
| `--continue` | Resumes the most recent session for this directory | Low |
| `--name "$(basename "$PWD")"` | Names the session after `$PWD` | Low |
| `--remote-control` | Enables Claude Code's Remote Control feature | **Verify in your installed `claude`** — run `claude --help \| grep -i remote-control`. Behavior has varied across Claude Code versions; some surface a network listener. If your `claude --help` doesn't list `--remote-control` (e.g. v2.1.x only shows `--remote-control-session-name-prefix`), the wrapper will still pass it — Claude may ignore unknown flags or error out. Edit `bashrc.d/10-dangerclaude.sh` to remove it if unwanted or unsupported. |
| `DISABLE_COMPACT=1` | Skips automatic context-compaction prompts | Low |

**Friend-protection tips:**

- Don't run on a machine with production credentials in `~/.aws/`, `~/.ssh/`, `.env` files, browser session storage, or password manager exports you can't afford to lose.
- Don't run inside repos containing files from untrusted sources (random GitHub clones, downloaded markdown, scraped content). Those files are read by Claude and can prompt-inject.
- The aliases use `--continue` per-directory; if you need a fresh session, run `claude` directly without the wrapper.
- TPM is pinned to `v3.1.0` in `install.sh`. To audit/update, see https://github.com/tmux-plugins/tpm/releases.

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
