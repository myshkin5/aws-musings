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

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" |"
SCM_THEME_PROMPT_SUFFIX="${green}|"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${green}|"
GIT_THEME_PROMPT_SUFFIX="${green}|"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function prompt_command() {
    PS1="\n$(clock_char) ${purple}\u@\h ${reset_color}in ${green}\w\n${bold_cyan}$(scm_char)${green}$(scm_prompt_info) ${green}→${reset_color} "
}

PROMPT_COMMAND=prompt_command;

# Load Bash It
source $BASH_IT/bash_it.sh
