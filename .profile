# ~/.profile - Shared configuration for all shells

# PATH setup for user-specific directories
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Modern CLI replacements
alias cat='batcat --paging=never --style=plain'
alias bat='batcat' # debian-based distros use 'batcat' to avoid conflict with the 'bat' package
alias ls='eza'
alias ll='eza -l'
alias la='eza -la'
alias tree='eza --tree'
alias oc='opencode'

# pnpm aliases
alias p="pnpm"
alias pw="pnpm run --workspace-root"

# Run command without TTY (strips colors, useful for piping)
function notty() {
  true | ($@) 2>&1 | cat
}

# Quick commit and push workflow (Work In Progress)
function wip() {
  git add -A && git commit && git pull --rebase && git push
}

# Quick commit and push without hooks (Force)
function wipf() {
  git add -A && git commit --no-verify && git pull --rebase && git push --no-verify
}
