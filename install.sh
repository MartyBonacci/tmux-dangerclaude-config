#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# tmux-dangerclaude-config install script
# Idempotent — safe to re-run any time.
#
# Actions:
#   1. Create ~/.dotfiles symlink pointing at this repo
#   2. Symlink ~/.tmux.conf and ~/.tmux-cheatsheet.txt into the repo
#   3. Append the bashrc.d sourcing loop to ~/.bashrc (guarded by marker)
#   4. Clone TPM (tmux plugin manager) if missing
#   5. Warn if the `claude` binary isn't on PATH
#
# Any existing non-symlink files at the symlink targets are backed up, not
# overwritten.
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Self-locate: the repo root is the directory containing this script,
# resolved to an absolute path so symlinks use a stable target.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Output helpers ────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
RESET='\033[0m'
ok()   { printf '%b✓%b %s\n' "$GREEN"  "$RESET" "$*"; }
warn() { printf '%b⚠%b %s\n' "$YELLOW" "$RESET" "$*"; }
err()  { printf '%b✗%b %s\n' "$RED"    "$RESET" "$*" >&2; }
info() { printf '%bℹ%b %s\n' "$CYAN"   "$RESET" "$*"; }

# ─── Symlink helper ────────────────────────────────────────────────────────
# Create or update $dst → $src. If $dst exists as a non-matching symlink or
# a real file, move it to a timestamped backup first.
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst already linked → $src"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    local backup="${dst}.backup.$(date +%s)"
    warn "$dst exists — backing up to $backup"
    mv "$dst" "$backup"
  fi
  ln -s "$src" "$dst"
  ok "linked $dst → $src"
}

info "installing from: $REPO"
echo

# ─── 1. ~/.dotfiles symlink (abstraction layer) ────────────────────────────
link "$REPO" "$HOME/.dotfiles"

# ─── 2. Tmux config symlinks ───────────────────────────────────────────────
link "$REPO/tmux.conf"           "$HOME/.tmux.conf"
link "$REPO/tmux-cheatsheet.txt" "$HOME/.tmux-cheatsheet.txt"

# ─── 3. Bashrc sourcing loop ───────────────────────────────────────────────
MARKER='# Load modular shell config from ~/.dotfiles/bashrc.d/'
BASHRC="$HOME/.bashrc"
if [ ! -f "$BASHRC" ]; then
  warn "$BASHRC does not exist — creating it"
  touch "$BASHRC"
fi
if grep -qF "$MARKER" "$BASHRC"; then
  ok "bashrc.d sourcing loop already present in ~/.bashrc"
else
  cat >> "$BASHRC" <<'EOF'

# Load modular shell config from ~/.dotfiles/bashrc.d/
# (~/.dotfiles is a symlink to the tmux-dangerclaude-config git repo)
if [ -d "$HOME/.dotfiles/bashrc.d" ]; then
  for _rc in "$HOME/.dotfiles/bashrc.d"/*.sh; do
    [ -r "$_rc" ] && source "$_rc"
  done
  unset _rc
fi
EOF
  ok "appended bashrc.d sourcing loop to ~/.bashrc"
fi

# ─── 4. TPM install ────────────────────────────────────────────────────────
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ -d "$TPM_DIR/.git" ]; then
  ok "TPM already installed at $TPM_DIR"
else
  info "cloning TPM (tmux plugin manager)..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM installed"
fi

# ─── 5. Claude binary sanity check ─────────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  ok "claude binary found: $(command -v claude)"
else
  warn "claude binary NOT found on PATH"
  warn "  The _dangerclaude aliases (skynet, t800, etc.) will not work until"
  warn "  Claude Code is installed. See:"
  warn "    https://docs.anthropic.com/claude/docs/claude-code"
fi

# ─── Done ──────────────────────────────────────────────────────────────────
echo
info "Next steps:"
echo "  1. source ~/.bashrc                       # reload shell functions"
echo "  2. t                                      # create/attach 'main' tmux"
echo "  3. (inside tmux) Ctrl+Space then Shift+I  # install tmux plugins"
echo
info "Cheat sheet: run 'tcheat' any time"
