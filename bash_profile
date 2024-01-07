# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/login.defs
umask 002

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Add user's private bins to PATH if they exist and
# are not already in PATH (duplicated in bashrc)
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

export XAUTHORITY=~/.Xauthority
