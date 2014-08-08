# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions

export PATH=$HOME/bin:$PATH
 
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
 
spwd ()
{
    SPWD=${PWD/$HOME/\~};
    if [ ${#SPWD} -gt 25 ]; then
        SPWD=...${SPWD:(-22)};
    fi;
    echo $* $SPWD
}
 
export EDITOR=vi
 
export PS1="\[\033[4;34m\]\u@\h\[\033[0m\]:\[\033[1;31m\]\`spwd -n\`\[\033[0m\]$ "
 
export FIGNORE=CVS:.svn:.git
export HISTCONTROL=ignoredups
