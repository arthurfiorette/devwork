# ~/.profile - Shared configuration for all shells

# PATH setup
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

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
