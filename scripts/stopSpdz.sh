#!/bin/bash
# Stop a SPDZ process.
# Chk to see if a docker container is running, and stop if FORCE_STOP is Y
# return status 0 for success / not running, non-zero otherwise.
# Interface must match spdz-proxy runSpdzFunction.
HERE=$(cd `dirname $0`; pwd)

PLAYER_ID=${1:-"none"}
FORCE_STOP=${2:-"N"}
CONTAINER_NAME="spdz-analytics-$PLAYER_ID"

if [ "$PLAYER_ID" == "none" ]; then
  (>&2 echo "No player id given.")
  exit 1
fi

if [ "$FORCE_STOP" != "Y" -a "$FORCE_STOP" != "N" ]; then
  (>&2 echo "Force stop must be Y or N")
  exit 1
fi

if [ -n "$(docker ps --filter name=$CONTAINER_NAME | grep -w $CONTAINER_NAME)" ]
then
  if [ "$FORCE_STOP" == "Y" ]; then
    echo "Container $CONTAINER_NAME is running, will try to stop"
    docker stop -t 0 $CONTAINER_NAME
    exit $?
  else
    (>&2 echo "Container $CONTAINER_NAME is running, but not requested to stop.")
    exit 1
  fi
fi

exit 0
