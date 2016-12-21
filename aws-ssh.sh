#!/usr/bin/env bash

echo
echo SSH to an AWS box
echo Version 1.0.4
echo

while getopts "r:e:n:" opt; do
  case $opt in
    r)
      role=${OPTARG^^}
      ;;
    e)
      env=${OPTARG^^}
      ;;
    n)
      n=${OPTARG^^}
      ;;
  esac
done

if [ -z $n ]; then
    # if not specified default to first box found
    n=1
fi

echo "Role = $role"
echo "Environment = $env"
echo "Number = $n"

ip=$(aws-ip.sh -e $env -r $role -n $n)

if [ -z $ip ]; then
  echo "IP not found"
else
  echo "IP = $ip"
  ssh $ip
fi
