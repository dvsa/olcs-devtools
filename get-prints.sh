#!/usr/bin/env bash

#
# Version 1.0
# Get all the printed files (PDF's) from the CUPS servers and sync them to tmp directory
#

usage() {
  echo "Usage:"
  echo "  get-prints.sh [-e <environment>]"
  echo
  echo "Options:"
  echo "  -e  Environment to get prints for eg QA. If not specified will get for all environments"
  echo
  exit;
}

while getopts "r:e:n:h" opt; do
  case $opt in
    e)
      env=${OPTARG^^}
      ;;
  esac
done

if [ -z $env ]; then
  usage "Environment must be specified with -e"
fi

IPs=$(aws-ip.sh -e $env -r PRINT)

if [ $? = 0 ]; then
  # convert env to lowercase as it is used for a directory name
  env="${env,,}"

  mkdir -p /tmp/print/$env
  while read IP; do
    rsync -avz -e ssh $IP:/var/spool/cups-pdf/ANONYMOUS/* /tmp/print/demo
  done <<< "$IPs"
else
  echo "Error getting IP addresses of CUPS servers"
fi
