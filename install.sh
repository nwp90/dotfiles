#!/bin/bash

if [ "$1" == "-f" ]; then
  CPARGS="-a"
else
  CPARGS="-ai"
fi

DOTFILES="bash_aliases bash_logout bash_profile bashrc emacs.d gitconfig hgext hgrc profile pylintrc xchat2"

for thing in $DOTFILES; do
  cp $CPARGS $thing ~/.$thing
done

for thing in $(ls bin); do
  install -D -m775 -onwp -gnwp bin/${thing} ~/bin/${thing}
done
