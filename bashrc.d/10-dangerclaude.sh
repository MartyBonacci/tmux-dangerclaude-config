# ═══════════════════════════════════════════════════════════════════════════
# _dangerclaude wrapper + Terminator-themed alias rotation
# Part of the tmux-dangerclaude-config dotfiles repo.
# ═══════════════════════════════════════════════════════════════════════════

# Danger-mode Claude Code wrapper with a rotation of Terminator-themed names.
# Single helper function + aliases — pick any of the names below based on demo
# mood. All call the same underlying wrapper so logic stays DRY.
# Features: skip all permission checks, continue prior session (remote-control
# mode handles fresh directories gracefully), name session after current
# directory, enable remote control, skip compact prompts.
_dangerclaude() {
  DISABLE_COMPACT=1 command claude \
    --dangerously-skip-permissions \
    --continue \
    --name "$(basename "$PWD")" \
    --remote-control \
    "$@"
}
alias 214am='_dangerclaude'
alias skynet='_dangerclaude'
alias t800='_dangerclaude'
alias t1000='_dangerclaude'
alias terminate='_dangerclaude'
alias trustmebro='_dangerclaude'
alias claudenator='_dangerclaude'
alias whatcouldgowrong='_dangerclaude'
