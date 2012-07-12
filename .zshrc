setopt promptsubst
autoload -U promptinit
promptinit
prompt grb

autoload -U compinit
compinit


autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

# ACTUAL CUSTOMIZATION OH NOES!
gd() { git diff $* | view -; }
gdc() { gd --cached $*; }
#alias tmux="TERM=screen-256color tmux new /bin/zsh"
alias tmux="TERM=screen-256color tmux -2"
alias pygrep="grep --include='*.py' $*"
alias rbgrep="grep --include='*.rb' $*"
alias r=rails
alias t="script/test $*"
alias f="script/features $*"
alias g="bundle exec guard $*"
alias sr="screen -r"
alias gx="gitx"
alias gxa="gitx --all"
function mcd() { mkdir -p $1 && cd $1 }
alias :q="echo YOU FAIL"
alias misc="cd /Volumes/misc"
function cdf() { cd *$1*/ } # stolen from @topfunky
function das() {
    cd ~/proj/destroyallsoftware.com/destroyallsoftware.com
    pwd
    export RUBY_HEAP_MIN_SLOTS=1000000
    export RUBY_HEAP_SLOTS_INCREMENT=1000000
    export RUBY_HEAP_SLOTS_GROWTH_FACTOR=1
    export RUBY_GC_MALLOC_LIMIT=1000000000
    export RUBY_HEAP_FREE_MIN=500000
    . /Volumes/misc/filing/business/destroy\ all\ software\ llc/s3.sh
    . /Volumes/misc/filing/business/destroy\ all\ software\ llc/braintree.sh
}

activate_virtualenv() {
    if [ -f env/bin/activate ]; then . env/bin/activate;
    elif [ -f ../env/bin/activate ]; then . ../env/bin/activate;
    elif [ -f ../../env/bin/activate ]; then . ../../env/bin/activate;
    elif [ -f ../../../env/bin/activate ]; then . ../../../env/bin/activate;
    fi
}

python_module_dir () {
    echo "$(python -c "import os.path as _, ${1}; \
        print _.dirname(_.realpath(${1}.__file__[:-1]))"
        )"
}

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
set -g default-terminal "screen-256color"

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



