# ═══════════════════════════════════════════════════════════════════════════
# dsync — push local config edits back into the dotfiles git repo
# Part of the tmux-dangerclaude-config dotfiles repo.
#
# Usage:
#   dsync                       Copy home configs → repo, then show diff
#   cd ~/.dotfiles && git add -A && git commit -m "tweak" && git push
#
# This function survives repo deletion because it's installed as a real
# copy in ~/.bashrc.d/, not symlinked. If the repo doesn't exist, it
# tells you how to re-clone.
# ═══════════════════════════════════════════════════════════════════════════

dsync() {
  local repo=""
  if [ -L "$HOME/.dotfiles" ] && [ -d "$HOME/.dotfiles/.git" ]; then
    repo="$(readlink -f "$HOME/.dotfiles")"
  elif [ -d "$HOME/code-projects/tmux-dangerclaude-config/.git" ]; then
    repo="$HOME/code-projects/tmux-dangerclaude-config"
  else
    echo "Dotfiles repo not found." >&2
    echo "  Expected: ~/.dotfiles symlink or ~/code-projects/tmux-dangerclaude-config/" >&2
    echo "  Re-clone: git clone git@github.com:MartyBonacci/tmux-dangerclaude-config.git <path>" >&2
    return 1
  fi

  local changed=0
  for pair in \
    "$HOME/.tmux.conf:$repo/tmux.conf" \
    "$HOME/.tmux-cheatsheet.txt:$repo/tmux-cheatsheet.txt" \
  ; do
    local src="${pair%%:*}" dst="${pair#*:}"
    if [ -f "$src" ] && ! diff -q "$src" "$dst" >/dev/null 2>&1; then
      cp "$src" "$dst"
      echo "  updated $(basename "$dst")"
      changed=1
    fi
  done

  mkdir -p "$repo/bashrc.d"
  for f in "$HOME/.bashrc.d"/*.sh; do
    local base="$(basename "$f")"
    if ! diff -q "$f" "$repo/bashrc.d/$base" >/dev/null 2>&1; then
      cp "$f" "$repo/bashrc.d/$base"
      echo "  updated bashrc.d/$base"
      changed=1
    fi
  done

  if [ "$changed" -eq 0 ]; then
    echo "Everything already in sync."
  else
    echo
    echo "Synced home → $repo"
    echo "  Review:  cd ~/.dotfiles && git diff"
    echo "  Commit:  cd ~/.dotfiles && git add -A && git commit -m 'update'"
    echo "  Push:    cd ~/.dotfiles && git push"
  fi
}
