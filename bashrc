# ~/.bashrc: -*- shell-script -*- executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# per-host settings
case $(/bin/hostname -s) in
    inf-*) ;&
    its-*)
        export EMACS_NOELPA=1
        ;;
esac

# Add user's private bins to PATH if they exist and
# are not already in PATH (duplicated in bash_profile)
#
for BIN in ${HOME}/.local/bin ${HOME}/bin ; do
  [ -d "${BIN}" ] || continue
  [[ ":${PATH}:" == *":${BIN}:"* ]] || PATH=${BIN}:${PATH}
done

if [ -d ~/go ]; then
  for BIN in ${HOME}/go/bin /usr/local/go/bin ; do
    [[ ":${PATH}:" == *":${BIN}:"* ]] || PATH=${BIN}:${PATH}
  done
  export GOBIN=~/go/bin
fi

if [ -f ~/.cargo/env ]; then
    . ~/.cargo/env
fi
if [ -d ~/.rye ]; then
    . ~/.rye/env
fi


export DEBEMAIL=nwp@debian.org
export DEBFULLNAME="Nick Phillips"
export HGMERGE=/usr/bin/meld
#export XAUTHORITY=${HOME}/.Xauthority
# The only one that makes sense
export LC_COLLATE=C

# Grrr... see https://github.com/oneapi-src/oneVPL/issues/56
# and then https://github.com/oneapi-src/oneAPI-spec/issues/418
export ONEVPL_SEARCH_PATH=/opt/intel/oneapi/vpl/latest/lib

# Because Grrr....
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# If not running interactively, don't do anything. Unless we've already done it.
case $- in
    *i*) ;;
      *) return;;
esac
# Old way of detecting interactive
#[ -z "$PS1" ] && return

export VISUAL=~/bin/edit
export EDITOR=${VISUAL}
export ALTERNATE_EDITOR=emacs

# Avoid "gpg: signing failed: Inappropriate ioctl for device" on `git tag -sf`
# https://gist.github.com/repodevs/a18c7bb42b2ab293155aca889d447f1b
export GPG_TTY=$(/usr/bin/tty)

# Don't pop up passphrase dialog in console GUI if I'm using ssh...
if [ -n "${SSH_CONNECTION}" ]; then
    export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# append to the history file, don't overwrite it
shopt -s histappend

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
#export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
#export HISTCONTROL=ignoreboth
#export HISTCONTROL=ignoredups
export HISTCONTROL=ignorespace
export HISTFILESIZE=15000
export HISTSIZE=15000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# dubious
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

envprompt=""
if [ -f /etc/profile.uoo ]; then
    . /etc/profile.uoo
    envprompt=$(environment_prompt_fragment)
elif [ -f /etc/profile.d/uoo_prompt.sh ]; then
    . /etc/profile.d/uoo_prompt.sh
    envprompt=$(environment_prompt_fragment)
fi

# Make sure __git_ps1 is available

__load_git_prompt() {
  # for RHEL; debian does it automatically for now
  # (but will use /usr/lib/git-core/git-sh-prompt when it doesn't)
  if [[ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]]; then
     . /usr/share/git-core/contrib/completion/git-prompt.sh
  fi
}

declare -F __git_ps1 > /dev/null || __load_git_prompt

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\!:\[\033[01;34m\]\w\[\033[00m\]$(__git_ps1)\$ '
    # newer?
	#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\!:\w$(__git_ps1)\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h:\!: \w\a\]$PS1"
#    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

if [ -n "${VIRTUAL_ENV}" ]; then
    venvprompt="(`basename \"$VIRTUAL_ENV\"`)"
    if [ -n "${envprompt}" ]; then
        venvprompt=" ${venvprompt}"
    fi
else
    venvprompt=""
fi

if [ -n "${envprompt}" ]; then
    PS1="${envprompt} ${venvprompt}${PS1}"
else
    PS1="${venvprompt}${PS1}"
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]  && [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    #alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.fontawesome-auth ]; then
    . ~/.fontawesome-auth
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi

  # Safer. If expecting a completion to stop before the end so you can add *,
  # but it completes, and you're not paying attention...
  #
  # Yes I have.
  #
  compopt -o nospace rm > /dev/null 2>&1

  # default Debian debsign completion is shit
  if [ -e /usr/share/bash-completion/completions/debsign ]; then
    __load_completion debsign && compopt -o dirnames debsign
  fi
fi

# Doesn't work when ssh versions out of sync between win & wsl
#[ -e "${HOME}/bin/win-ssh-agent.sh" ] && . "${HOME}/bin/win-ssh-agent.sh"

if /usr/bin/uname -r | /bin/grep -q microsoft ; then
    echo "On WSL, sourcing startup..." >&2
    [ -e ~/bin/start.sh ] && . ~/bin/start.sh
fi

