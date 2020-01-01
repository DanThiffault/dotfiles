fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

export PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/opt/ruby/bin:$HOME/.local/bin:$HOME/bin

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

export EC2_HOME=~/.ec2

# Grab the contents from secret file not checked in
source $HOME/.zsh_secret
