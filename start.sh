#!/bin/bash

# show us where we have failed you
set -o nounset -o errexit 

# report issues
usage() {
  echo "Usage: ./start.sh [ roadrunner | hummbee ] <... arguments ...>"
  exit 1
}

# not enough arguments? we have failed
if [ "$#" -lt 1 ]; then
    usage
fi

# what app are we trying to use?
APP=$1; shift

# does it exist?
if [ ! -x /libra/apps/install/$APP ]; then
    "Error: unable to locate $APP in /libra/apps/install"
    usage
fi

# it must exist, so let's proceed
echo "passing command line arguments to $APP: $@"

/libra/apps/install/$APP $@ 

