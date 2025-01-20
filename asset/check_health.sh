#!/bin/bash
#

if [ ! -f agent/work/mid.pid ]
then
  echo "agent/work/mid.pid doesn't exist"
  exit 1
fi

if [ ! -f agent/.healthcheck ]
then
  echo "agent/.healthcheck doesn't exist"
  exit 1
fi

# check if currentTime - lastModifiedTime of .healthcheck is >= 30 min (1800 sec) \
currentTime=`date '+%s'`
lastModifiedTime=`date -r agent/.healthcheck '+%s'`

if [ $(($currentTime-$lastModifiedTime)) -gt 1800 ]
then
  exit 1
fi

exit 0