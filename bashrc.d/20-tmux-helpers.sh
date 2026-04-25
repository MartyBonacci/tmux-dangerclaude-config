# ═══════════════════════════════════════════════════════════════════════════
# Tmux helpers — multi-device persistent session workflow
# Desktop is the persistence anchor; laptop + phone attach via SSH.
# Part of the tmux-dangerclaude-config dotfiles repo.
# ═══════════════════════════════════════════════════════════════════════════

# Attach to a session, or create it if it doesn't exist.
# Default session name is "main".
#   t              → attach to "main" (create if needed)
#   t myproject    → attach to "myproject" (create if needed)
t() {
  local name="${1:-main}"
  tmux attach -t "$name" 2>/dev/null || tmux new -s "$name"
}

# List all running tmux sessions.
tl() { tmux list-sessions 2>/dev/null || echo "(no tmux server running)"; }

# Kill a session by name.
tk() { tmux kill-session -t "${1:?usage: tk SESSION}"; }

# Switch to a different session from WITHIN a tmux client.
ts() { tmux switch-client -t "${1:?usage: ts SESSION}"; }

# Display the tmux + claude cheat sheet.
# Content lives in ~/.tmux-cheatsheet.txt so it can be edited independently.
tcheat() {
  local sheet="$HOME/.tmux-cheatsheet.txt"
  if [ -f "$sheet" ]; then
    cat "$sheet"
  else
    echo "Cheat sheet not found: $sheet" >&2
    return 1
  fi
}

# ─── SSH auto-attach ──────────────────────────────────────────────────────
# When you SSH in from a laptop or phone, drop directly into the "main"
# tmux session. Two commands from lock screen to working:
#   unlock → ssh desktop → (you're in tmux, see your last state)
# Conditions: only on SSH, only if not already in tmux, only interactive shells.
# Opt out by exporting TMUX_AUTO_ATTACH=0 in ~/.bash_profile or login env.
if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && $- == *i* && "${TMUX_AUTO_ATTACH:-1}" == "1" ]]; then
  t main
fi
