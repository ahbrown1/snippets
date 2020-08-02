#!/bin/bash
#
#=====================================================================================================
# Execute a shell command or script until it succeeds or the maximum number of retries is exceeded.
# Retry delay can be:
#  * constant : set delay backoff to 1
#  * exponential: e.g., set backoff to 2 to double the wait interval between each retry
#
# Usage: retry <max tries> <initial retry delay> <delay backoff> <command> [<command args> ...]
#
# Inspired by fernandoacorreia/azure-docker-registry in GitHub,com
# Licensed under the MIT License
#
# Example:
# $ source ./retry.sh
# $ retry 4 10 1 echo OK 			# works with no retries 
# $ retry 4 10 1 pip install no_such_thing 	# fails after 4 attempts in 10 second intervals
#
#=====================================================================================================


function fail {
  set -e
  echo $1 >&2
  false
}


function retry {

  local n=1
  local usage='retry <max tries> <initial retry delay> <delay backoff> <command> [<command args> ...]' 
  if [[ $# -lt 4 ]] ; then
     fail "ERROR: Usage: $usage"
  fi
  local max=$1;     shift
  local delay=$1;   shift
  local backoff=$1; shift

  while true; do
    "$@" && break || {
      if [[ $n -lt $max ]]; then
        ((n++))
        echo "WARNING: The command [ $@ ] failed. Attempt $n/$max: will retry in $delay seconds ..."
        sleep $delay;
        delay=$(( backoff*delay ))
      else
        fail "ERROR: The command [ $@ ] has failed after $n attempts."
      fi
    }
  done
}

