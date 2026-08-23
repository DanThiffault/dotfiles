setopt promptsubst
autoload -U promptinit
promptinit
prompt grb

autoload -U compinit
compinit


autoload -U edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# ACTUAL CUSTOMIZATION OH NOES!
gd() { git diff $* | view -; }
gdc() { gd --cached $*; }
alias :q="echo YOU FAIL"
#alias open="xdg-open"

set -g default-terminal "screen-256color"

# By @ieure; copied from https://gist.github.com/1474072
#
# It finds a file, looking up through parent directories until it finds one.
# Use it like this:
#
#   $ ls .tmux.conf
#   ls: .tmux.conf: No such file or directory
#
#   $ ls `up .tmux.conf`
#   /Users/grb/.tmux.conf
#
#   $ cat `up .tmux.conf`

function up()
{
    if [ "$1" != "" -a "$2" != "" ]; then
        local DIR=$1
        local TARGET=$2
    elif [ "$1" ]; then
        local DIR=$PWD
        local TARGET=$1
    fi
    while [ ! -e $DIR/$TARGET -a $DIR != "/" ]; do
        DIR=$(dirname $DIR)
    done
    test $DIR != "/" && echo $DIR/$TARGET
}

export EDITOR=/opt/homebrew/bin/vim

# Launch gpg-agent
gpg-connect-agent /bye

# When using SSH support, use the current TTY for passphrase prompts
# gpg-connect-agent updatestartuptty /bye > /dev/null

# Point the SSH_AUTH_SOCK to the one handled by gpg-agent
if [ -S $(gpgconf --list-dirs agent-ssh-socket) ]; then
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
else
  echo "$(gpgconf --list-dirs agent-ssh-socket) doesn't exist. Is gpg-agent running ?"
fi

# killall gpg-agent && gpg-agent --daemon --pinentry-program /usr/local/bin/pinentry

export LDFLAGS="-L/usr/local/opt/ruby/lib"
export CPPFLAGS="-I/usr/local/opt/ruby/include"
export PKG_CONFIG_PATH="/usr/local/opt/ruby/lib/pkgconfig"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source ~/.zsh/plugins/zsh-nix-shell/nix-shell.plugin.zsh

source $HOME/.zsh/plugins/nix-zsh-completions/nix-zsh-completions.plugin.zsh
fpath=($HOME/.zsh/plugins/nix-zsh-completions $fpath)
autoload -U compinit && compinit


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/dan/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/dan/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/dan/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/dan/google-cloud-sdk/completion.zsh.inc'; fi


export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export KUBECTL_EXTERNAL_DIFF="colordiff -N -u"
