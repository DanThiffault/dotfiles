fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

export PATH=$HOME/bin:$HOME/.rvm/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin

export PATH=$PATH:$HOME/.ec2/bin
export PATH=$PATH:/usr/local/mysql/bin

# Add postgres to the path
export PATH=$PATH:/usr/local/pgsql/bin
export PATH=$PATH:/Library/PostgreSQL/8.3/bin



# Unbreak broken, non-colored terminal
export TERM='xterm-color'
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
# GNU Screen sets -o vi if EDITOR=vi, so we have to force it back. What the
# hell, GNU?
set -o emacs

# Unbreak Python's error-prone .pyc file generation
export PYTHONDONTWRITEBYTECODE=1

export WORDCHARS='*?[]~&;!$%^<>'

export ACK_COLOR_MATCH='red'



[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 