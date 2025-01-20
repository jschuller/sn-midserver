#!/bin/bash
#
# Sample variable
#   mid_installation_url =

set -e

mid_installation_url=$1

if [[ ! -z "$mid_installation_url" ]]
then
  echo "Downloading $mid_installation_url"
  wget $mid_installation_url -O /tmp/mid.zip
else
  echo "ERROR: Downloading [$mid_installation_url] failed!"
  exit 1
fi
