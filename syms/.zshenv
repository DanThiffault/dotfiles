fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

export PATH=$PATH:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin:/usr/local/opt/ruby/bin:$HOME/.local/bin:$HOME/bin:$HOME/.vim/bundle/vim-iced/bin

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

export AWS_VAULT_BACKEND=secret-service
# wrapper for aws-vault
# usage: awsv ROLE AWSCLI-COMMAND AWSCLI-ARGS
#   e.g. `awsv ro s3 ls s3://foobucket`
function awsv () {
    local role="$1"
    shift
    aws-vault exec "$role" -- aws "$@"
}

# wrap a nix-shell in an aws-vault session
# usage: `vault-nix ROLE [optional args for nix-shell]`
function vault-nix () {
    local role="$1"
    shift
    aws-vault exec "$role" -- nix-shell "$@"
}

alias aws="aws-vault exec ro -- aws"
alias aws-rw="aws-vault exec rw -- aws"
alias aws-superadmin="aws-vault exec superadmin -- aws"

# Grab the contents from secret file not checked in
source $HOME/.zsh_secret

