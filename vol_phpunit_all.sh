#!/bin/bash

# Exit if PHP version isn't right
currentphp=$(php -r 'echo phpversion();')
if [ $currentphp != 7.4.33 ]; then
 printf "\\tPHP is $currentphp - must be 7.4.33, run from container\\n"
 exit
fi

# Start with new output file every time
testOutput=$OLCS_APP_DIR/vol_unit_test_results.txt
if [[ -f "$testOutput" ]]; then
  rm "$testOutput"
fi
touch "$testOutput"

projects=(
olcs-auth
olcs-backend
olcs-common
olcs-companies-house
olcs-cpms
olcs-etl
olcs-internal
olcs-logging
olcs-selfserve
olcs-transfer
olcs-utils
olcs-xmltools
)

# All use test/* and have Bootstrap.php, except:
# olcs-backend - needs test/src
# olcs-companies-house - no bootstrap
# olcs-cpms - no bootstrap

# olcs-static - none (has a test folder for js)
# olcs-devtools, olcs-elasticsearch, olcs-frontend-deps, olcs-laminas - none
# olcs-maintenance-page, olcs-testhelpers - none

unitTest() {
    printf "Project: $1\\n"
    testCommand=("./vendor/bin/phpunit test")

    bootstrapPath="test/Bootstrap.php"
    printf "\\tChecking for Bootstrap in $bootstrapPath...\\n"

    if [[ -f "$bootstrapPath" ]]; then
        printf "\\tFound $1/$bootstrapPath  ...\\n"
        testCommand="./vendor/bin/phpunit test --bootstrap test/Bootstrap.php"
    fi

    # Regardless of Bootstrap, always specify xml for backend
    if [ "$1" == "olcs-backend" ]; then
        testCommand="./vendor/bin/phpunit -c test/phpunit.xml"
    fi

    printf "Running $(IFS= ; echo "${testCommand[*]}")  \\n"

    # testCommand never contains user input
    eval "$(IFS= ; echo "${testCommand[*]}")"
}

for project in "${projects[@]}"; do
  if [ -d "$project/test" ]; then
    printf "\\tRunning phpunit tests in $project... \\n"
    cd "$project" || return

    unitTest $project >> "$testOutput"

    cd ..
  fi
done

# Summarise output
# ToDo: Aggregate maybe...?
printf "\\nSummary: \\n"
awk '/Project:|[Tt]ests/' "$testOutput"
printf "\\n(full results in: $testOutput) \\n"
printf "\\nDone \\n"
