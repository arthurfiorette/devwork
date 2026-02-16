# ~/.zshrc - Zsh-specific configuration

# History configuration
export HISTFILE=~/shell-history/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# Oh My Zsh plugins
plugins=(autoupdate z git docker docker-compose npm node zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete gh)

# Load Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

# Load Starship prompt
eval "$(starship init zsh)"

# Load shared profile
if [ -f ~/.profile ]; then
    . ~/.profile
fi
