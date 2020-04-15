#!/bin/bash

if [ "$1" == "-f" ]; then
  CPARGS="-a"
else
  CPARGS="-ai"
fi

# Don't include bash-completions here; it's special.
DOTFILES="bash_aliases bash_logout bash_profile bashrc emacs.d gitconfig hgext hgrc profile pylintrc xchat2"

for thing in $DOTFILES; do
  if diff -urN ~/".$thing" "$thing" ; then
    echo "$thing already installed"
  else
    echo "Installing $thing"
    if [ -d ~/".$thing" ]; then
      cp $CPARGS "$thing"/* ~/".$thing/"
    else
      cp $CPARGS "$thing" ~/".$thing"
    fi
  fi
done

for thing in $(ls bin); do
  if diff -urN ~/bin/"$thing" "bin/$thing" ; then
    echo "$thing already installed"
  else
    echo "Installing bin/$thing"
    if [ -d ~/bin/"$thing" ]; then
      echo "bin/$thing is a directory; ignoring"
    else
      install -D -m775 -o$(whoami) -g$(whoami) bin/"${thing}" ~/bin/"${thing}"
    fi
  fi
done

# Bash completion

LOCAL_COMPLETIONS_DIR=${BASH_COMPLETION_USER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion}/completions

__find_completion() {
  local -a dirs=()
  local OIFS=$IFS IFS=: dir cmd="${1##*/}" compfile
  [[ -n $cmd ]] || return 1
  for dir in ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
    dir="${dir%%/}"
    #echo "Adding dir to search: $dir"
    dirs+=( $dir/bash-completion/completions )
  done
  IFS=$OIFS

  for dir in "${dirs[@]}"; do
    #echo "Checking for dir '$dir'..."
    [[ -d "$dir" ]] || continue
    for compfile in "$cmd" "$cmd.bash" "_$cmd"; do
      compfile="$dir/$compfile"
      echo "Checking for '$compfile'..."
      [[ -f "$compfile" ]] && return 0
    done
  done
  return 1
}

if [ ! -d  ${LOCAL_COMPLETIONS_DIR} ]; then
  install -d -m700 -o$(whoami) -g$(whoami) ${LOCAL_COMPLETIONS_DIR}
fi

for cmd in $(ls bash-completions); do
  echo "Checking bash completion for '$cmd'..."
  __find_completion "$cmd" && echo "Completion found." || (echo "Installing completion for '$cmd'."; cp $CPARGS "bash-completions/$cmd" "${LOCAL_COMPLETIONS_DIR}/$cmd")
done
