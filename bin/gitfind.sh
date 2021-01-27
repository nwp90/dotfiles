#!/bin/sh

# inspired by this SO answer by Uwe Geuder
# http://stackoverflow.com/questions/277546/can-i-use-git-to-search-for-matching-filenames-in-a-repository/6960138#6960138
# this will create one 'foundin-$rev.txt' file for each of your revisions, feel free to delete them after use

# ADJUST THIS TO YOUR NEEDS:
SEARCHTERM=$1


allrevs=$(git rev-list --all)
# well, nearly all revs, we could still check the log if we have
# dangling commits and we could include the index to be perfect...

for rev in $allrevs
do
    echo "Working on $rev"
    git ls-tree --full-tree -r $rev | grep $SEARCHTERM >  foundin-$rev.txt
done

grep $SEARCHTERM foundin-*

