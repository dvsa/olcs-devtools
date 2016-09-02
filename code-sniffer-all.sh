#!/usr/bin/env bash

WORKSPACE=${dev_workspace}
PHPCS_SEVERITY=1
THIS_PATH="`dirname \"$0\"`"
THIS_SCRIPT="`basename \"$0\"`"
THIS_DIR="`basename \"$PWD\"`"
PHPCS="${THIS_PATH}/vendor/bin/phpcs"

echo
echo "Generate a CSV file of coding standards issues for all repos"
echo

CS="${THIS_PATH}/code-sniffer.sh"

$CS ${THIS_PATH}/../olcs-logging/src olcs-logging.csv
$CS ${THIS_PATH}/../olcs-auth/src olcs-auth.csv
$CS ${THIS_PATH}/../olcs-utils/src olcs-utils.csv
$CS ${THIS_PATH}/../olcs-transfer/src olcs-transfer.csv

$CS ${THIS_PATH}/../olcs-common/Common olcs-common.csv
$CS ${THIS_PATH}/../olcs-selfserve/module olcs-selfserve.csv
$CS ${THIS_PATH}/../olcs-internal/module olcs-internal.csv
$CS ${THIS_PATH}/../olcs-backend/module olcs-backend.csv
