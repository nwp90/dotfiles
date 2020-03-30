#!/bin/bash

if [ "$1" == "-f" ]; then
  CPARGS="-a"
else
  CPARGS="-ai"
fi

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
	  install -D -m775 -onwp -gnwp bin/"${thing}" ~/bin/"${thing}"
      fi
  fi
done
