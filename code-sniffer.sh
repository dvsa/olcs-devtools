#!/usr/bin/env bash

PATH_TO_CHECK=$1
CSV_FILE=$2
WORKSPACE=${dev_workspace}
PHPCS_SEVERITY=1
THIS_PATH="`dirname \"$0\"`"
THIS_SCRIPT="`basename \"$0\"`"
THIS_DIR="`basename \"$PWD\"`"
PHPCS="${THIS_PATH}/vendor/bin/phpcs"

echo
echo "Generate a CSV file of coding standards issues"
echo
echo "Usage ${THIS_SCRIPT} [path_or_file] [csv_file]"
echo "  [path_or_file] path or file to check"
echo "  [csv_file]     file name to write issues to. Default to current directory name Eg (${THIS_DIR}.csv)"
echo

if [ -z $PATH_TO_CHECK ]; then
  echo "Error : Specify a path or file to check. Eg ${THIS_SCRIPT} module"
  exit
fi

if [ -z $CSV_FILE ]; then
  CSV_FILE=${THIS_DIR}.csv
fi

$PHPCS --report=csv --severity=$PHPCS_SEVERITY --standard="${WORKSPACE}/sonar-configuration/Profiles/DVSA/CS/ruleset.xml" $PATH_TO_CHECK > $CSV_FILE