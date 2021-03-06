# Path to your oh-my-zsh installation.
export ZSH="/home/$USER/.oh-my-zsh"
setopt HIST_IGNORE_DUPS
bindkey \^U backward-kill-line # Ctrl+u kills from cursor backwards
ZSH_THEME="agnoster"
source ~/.bash_aliases
# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"
 #Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"
# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
alias zshconfig="vim ~/.zshrc && source ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
PROMPT="$PROMPT
$ "

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#determines search program for fzf
if type ag &> /dev/null; then
    export FZF_DEFAULT_COMMAND='ag -p ~/.gitignore -g ""'
fi
# prefer rg over ag
if type rg &> /dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden'
fi

if [[ $TERM != "eterm-color" ]]; then
    export TERM=xterm-256color
fi

PATH="$HOME/.local/bin:$PATH"
PATH="$PATH:/opt/bin"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi
