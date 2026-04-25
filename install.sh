#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# tmux-dangerclaude-config install script
# Idempotent — safe to re-run any time.
#
# All config files are COPIED (not symlinked) into your home directory.
# This means everything keeps working even if you delete this repo.
# To push edits back into the repo, use the `dsync` command.
#
# Actions:
#   1. Create ~/.dotfiles convenience symlink (optional, nothing depends on it)
#   2. Copy tmux.conf → ~/.tmux.conf
#   3. Copy tmux-cheatsheet.txt → ~/.tmux-cheatsheet.txt
#   4. Copy bashrc.d/*.sh → ~/.bashrc.d/
#   5. Append bashrc.d sourcing loop to ~/.bashrc (guarded by marker)
#   6. Clone TPM if missing
#   7. Warn if `claude` isn't on PATH
# ═══════════════════════════════════════════════════════════════════════════

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── Output helpers ────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'
ok()   { printf '%b✓%b %s\n' "$GREEN"  "$RESET" "$*"; }
warn() { printf '%b⚠%b %s\n' "$YELLOW" "$RESET" "$*"; }
info() { printf '%bℹ%b %s\n' "$CYAN"   "$RESET" "$*"; }

# ─── Install helper: copy $src → $dst ──────────────────────────────────────
# - If $dst is a symlink: replace it with a real copy (migration from old setup)
# - If $dst is a file with identical content: skip
# - If $dst is a file with different content: back up, then copy
install_file() {
  local src="$1" dst="$2"

  if [ -L "$dst" ]; then
    rm "$dst"
    cp "$src" "$dst"
    ok "installed $dst (replaced symlink with copy)"
    return
  fi

  if [ -f "$dst" ] && diff -q "$src" "$dst" >/dev/null 2>&1; then
    ok "$dst already up to date"
    return
  fi

  if [ -e "$dst" ]; then
    local backup="${dst}.backup.$(date +%s)"
    warn "$dst differs — backing up to $(basename "$backup")"
    mv "$dst" "$backup"
  fi

  cp "$src" "$dst"
  ok "installed $dst"
}

# ─── Symlink helper (for convenience links only) ───────────────────────────
link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    ok "$dst already linked"
    return
  fi
  [ -e "$dst" ] || [ -L "$dst" ] && rm "$dst"
  ln -s "$src" "$dst"
  ok "linked $dst → $src"
}

info "Installing from: $REPO"
echo

# ─── 1. ~/.dotfiles convenience symlink ─────────────────────────────────────
# Nothing depends on this. It just makes `cd ~/.dotfiles` and `dsync` work.
link "$REPO" "$HOME/.dotfiles"

# ─── 2. Copy tmux configs ───────────────────────────────────────────────────
install_file "$REPO/tmux.conf"           "$HOME/.tmux.conf"
install_file "$REPO/tmux-cheatsheet.txt" "$HOME/.tmux-cheatsheet.txt"

# ─── 3. Copy bashrc.d modules ───────────────────────────────────────────────
mkdir -p "$HOME/.bashrc.d"
for f in "$REPO/bashrc.d"/*.sh; do
  install_file "$f" "$HOME/.bashrc.d/$(basename "$f")"
done

# ─── 4. Bashrc sourcing loop ────────────────────────────────────────────────
MARKER='# Load modular shell config from ~/.bashrc.d/'
BASHRC="$HOME/.bashrc"
[ -f "$BASHRC" ] || touch "$BASHRC"
if grep -qF "$MARKER" "$BASHRC"; then
  ok "bashrc.d sourcing loop already present in ~/.bashrc"
else
  BASHRC_BLOCK=$(cat <<'EOF'

# Load modular shell config from ~/.bashrc.d/
# (installed by tmux-dangerclaude-config — survives repo deletion)
if [ -d "$HOME/.bashrc.d" ]; then
  for _rc in "$HOME/.bashrc.d"/*.sh; do
    [ -r "$_rc" ] && source "$_rc"
  done
  unset _rc
fi
EOF
)
  info "About to append the following to $BASHRC:"
  echo
  printf '%s\n' "$BASHRC_BLOCK" | sed 's/^/    /'
  echo

  proceed=0
  if [ "${INSTALL_YES:-0}" = "1" ]; then
    proceed=1
  elif [ -t 0 ]; then
    if read -r -p "Append this to ~/.bashrc? [y/N] " reply && [[ "$reply" =~ ^[Yy] ]]; then
      proceed=1
    else
      warn "Skipped ~/.bashrc modification per user response."
      warn "Re-run with INSTALL_YES=1 to apply non-interactively, or paste the block above manually."
    fi
  else
    warn "Non-interactive run with INSTALL_YES unset — skipping ~/.bashrc modification."
    warn "Re-run with INSTALL_YES=1 to apply non-interactively, or paste the block above manually."
  fi

  if [ "$proceed" = "1" ]; then
    printf '%s\n' "$BASHRC_BLOCK" >> "$BASHRC"
    ok "appended bashrc.d sourcing loop to ~/.bashrc"
  fi
fi

# ─── 5. TPM ─────────────────────────────────────────────────────────────────
# Pinned to a known release for supply-chain safety. Update consciously by
# changing TPM_REF below, or override at install time:
#   TPM_REF=master ./install.sh
# Releases: https://github.com/tmux-plugins/tpm/releases
TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REF="${TPM_REF:-v3.1.0}"
if [ -d "$TPM_DIR/.git" ]; then
  ok "TPM already installed (this script does not auto-update existing installs)"
else
  info "Cloning TPM (tmux plugin manager) at $TPM_REF..."
  git clone --depth 1 --branch "$TPM_REF" https://github.com/tmux-plugins/tpm "$TPM_DIR"
  ok "TPM installed at $TPM_REF"
fi

# ─── 6. Claude sanity check ─────────────────────────────────────────────────
if command -v claude >/dev/null 2>&1; then
  ok "claude binary found: $(command -v claude)"
else
  warn "claude binary NOT found on PATH"
  warn "  The _dangerclaude aliases (skynet, t800, etc.) won't work until"
  warn "  Claude Code is installed."
fi

# ─── Done ────────────────────────────────────────────────────────────────────
echo
info "Done! Next steps:"
echo "  1. source ~/.bashrc                       # reload shell functions"
echo "  2. t                                      # create/attach 'main' tmux"
echo "  3. (inside tmux) Ctrl+Space then Shift+I  # install tmux plugins"
echo
info "Cheat sheet: run 'tcheat' any time"
info "Sync edits back to repo: run 'dsync'"
