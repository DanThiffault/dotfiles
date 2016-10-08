fpath=($fpath $HOME/.zsh/func)
typeset -U fpath

export PATH=$HOME/bin:~/.rbenv/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/X11/bin

export PATH=$PATH:$HOME/.ec2/bin
export PATH=$PATH:/usr/local/mysql/bin

# Add postgres to the path
export PATH=$PATH:/usr/local/pgsql/bin
export PATH=$PATH:/Library/PostgreSQL/8.3/bin
export PATH=$HOME/lello/node_modules/.bin/:$PATH


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
# GNU Screen sets -o vi if EDITOR=vi, so we have to force it back. What the
# hell, GNU?
set -o emacs

# Unbreak Python's error-prone .pyc file generation
export PYTHONDONTWRITEBYTECODE=1

export WORDCHARS='*?[]~&;!$%^<>'

export ACK_COLOR_MATCH='red'

export EC2_HOME=~/.ec2
export S3_BUCKET="studentsourcinguploads-asia"
export S3_REGION="ap-southeast-1"

 # Java settings #################################################################
 export CATALINA_HOME=/Library/JavaDev/apache-tomcat-6.0.20

 export JRUBY_HOME=/Library/JavaDev/jruby
 export JRUBY_HOME=/Library/JavaDev/jruby-1.5.3

 # export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6.0/Home
 export JAVA_HOME=/Library/Java/JavaVirtualMachines/1.7.0/Contents/Home

 export M2_HOME=/Library/JavaDev/apache-maven-3.0.3

 export MAVEN_OPTS="-Xmx1024m -Xms64m -XX:MaxPermSize=512M -Dcom.sun.management.jmxremote"
 export ANT_HOME=/Library/JavaDev/apache-ant-1.7.0 
 export SBT_OPTS=-XX:MaxPermSize=256M
 ################################################################################
 
# Grab the contents from secret file not checked in
source $HOME/.zsh_secret

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 
