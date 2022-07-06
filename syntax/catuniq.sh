#!/usr/bin/env sh

#
# output lines in the second file which are not in the first, ignoring case and whitespace
# note: `read` strips whitespace
#
catuniq() {
  echo "\n===== $(basename $2)\n"
  cat $2 | while read line; do

    ## BROKEN: can't get the escaping right
    [ "$line" ] && grep --quiet --ignore-case --fixed-string \""${line%-}\"" "$1" || echo $line
  done
}

