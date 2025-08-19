# Minimal Zsh config (essentials only)
export ZSH="$HOME/.oh-my-zsh"

# Theme and plugins: keep defaults minimal
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# History
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# Basics
export EDITOR="nvim"
export PATH="/opt/homebrew/bin:$PATH"
