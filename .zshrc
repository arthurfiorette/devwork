# History configuration
export HISTFILE=~/shell-history/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# Path configuration
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

# Oh My Zsh plugins
plugins=(autoupdate z git docker docker-compose npm node zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete gh)

# Load Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Load Starship prompt
eval "$(starship init zsh)"
