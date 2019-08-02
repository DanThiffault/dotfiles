fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

export PATH=~/.rbenv/shims:$HOME/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin

# Unbreak broken, non-colored terminal
export TERM='screen-256color'
alias ls='ls -G'
alias ll='ls -lG'
alias duh='du -csh'
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"
export GREP_OPTIONS="--color"

# Unbreak history
export HISTSIZE=100000
export HISTFILE="$HOME/.history"
export SAVEHIST=$HISTSIZE

export EDITOR=vi
set -o vi

# Unbreak Python's error-prone .pyc file generation
export PYTHONDONTWRITEBYTECODE=1

export WORDCHARS='*?[]~&;!$%^<>'

export ACK_COLOR_MATCH='red'

export EC2_HOME=~/.ec2

# Grab the contents from secret file not checked in
source $HOME/.zsh_secret
