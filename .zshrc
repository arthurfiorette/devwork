# ~/.zshrc - Zsh-specific configuration

# History configuration
export HISTFILE="$HOME/shell-history/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
export ZSH="$HOME/.oh-my-zsh"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Oh My Zsh plugins
plugins=(autoupdate z git docker docker-compose npm node zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete gh)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Load Starship prompt
eval "$(starship init zsh)"

# Load shared profile
if [ -f ~/.profile ]; then
    . ~/.profile
fi