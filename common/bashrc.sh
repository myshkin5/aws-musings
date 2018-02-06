# User specific aliases and functions

export PATH=$HOME/bin:$PATH

alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'

export EDITOR=vi

export FIGNORE=CVS:.svn:.git

# Path to the bash it configuration
export BASH_IT="$HOME/.bash_it"

# Your place for hosting Git repos. I use this for private repos.
export GIT_HOSTING='git@github.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
export TODO="t"

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

function prompt_command() {
    PS1="$(clock_prompt)${yellow}|\u@\h|${green}\w ${bold_cyan}$(scm_char)${green}$(scm_prompt_info)${green}→${reset_color} "
}

export THEME_CLOCK_FORMAT="%dT%H:%M:%S"

PROMPT_COMMAND=prompt_command;

# Load Bash It
source $BASH_IT/bash_it.sh
