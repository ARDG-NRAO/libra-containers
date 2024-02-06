#!/bin/bash

# show us where we have failed you
set -o nounset -o errexit 

# report issues
usage() {
  echo "Usage: ./start.sh [ roadrunner | hummbee ] <... arguments ...>"
  exit 1
}

# check for help flag
if [[ "$1" == "--help" ]]; then
  usage
fi

# check for override flag
if [[ "$1" == "--override" ]]; then
  exec /bin/bash
fi

# not enough arguments? we have failed
if [ "$#" -lt 1 ]; then
    usage
fi

# what app are we trying to use?
APP=$1; shift

# does it exist?
if [ ! -x /data/libra/apps/install/$APP ]; then
    "Error: unable to locate $APP in /data/libra/apps/install"
    usage
fi

# it must exist, so let's proceed
echo "passing command line arguments to $APP: $@"

/data/libra/apps/install/$APP $@ 