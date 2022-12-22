fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

# Unbreak broken, non-colored terminal
export TERM='screen-256color'
alias ls='ls -G'
alias ll='ls -lG'
alias duh='du -csh'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

# Unbreak history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

set -o vi

# Unbreak Python's error-prone .pyc file generation
export PYTHONDONTWRITEBYTECODE=1

export WORDCHARS='*?[]~&;!$%^<>'

export ACK_COLOR_MATCH='red'


# Grab the contents from secret file not checked in
source $HOME/.zsh_secret
