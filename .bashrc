# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

#showing git branches in bash prompt
function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

function oc_project {
    if which oc &> /dev/null; then
        CONTEXT=$(oc whoami -c)
        echo "(${CONTEXT%%:*})"
    fi
}

function proml {
  local         RED="\[\033[0;31m\]"
  local   LIGHT_RED="\[\033[1;31m\]"
  local      YELLOW="\[\033[0;33m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local       WHITE="\[\033[1;37m\]"
  local  LIGHT_GRAY="\[\033[0;37m\]"
  local LIGHT_PURPLE="\[\033[0;34m\]"
  local       GREEN="\[\033[0;32m\]"
  local          NC="\e[0m"          # Text Reset / No Color
  case $TERM in
    xterm*)
        TITLEBAR='\[\033]0;\u@\h:\w\007\]'
    ;;
    *)
    TITLEBAR=""
    ;;
  esac

  user='\u'
  if [ ${USER} == "root" ]; then
      user=${YELLOW}'\u'${NC}
  fi

  PS1="${TITLEBAR}[${user}@\h ${LIGHT_RED}\w${NC}${LIGHT_GRAY}\$(parse_git_branch)${NC} ${LIGHT_PURPLE}\$(oc_project)${NC}]\n\$ "
PS2='> '
PS4='+ '
}
proml

. ~/.bash_aliases

unset command_not_found_handle
export PYTHONPATH="/home/vpavlin/.local/lib/python2.7/site-packages:${PYTHONPATH}"

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
export GOROOT="/usr/lib/golang" # Add GOROOT
export GOPATH="$HOME/devel/" # Add GOPATH
export PATH="$PATH:$GOROOT/bin:$HOME/devel/upstream/golang/bin" # Add GOROOT/bin to PATH

export GH=${HOME}/devel/github.com/vpavlin/
export GL=${HOME}/devel/gitlab.com/vpavlin/

