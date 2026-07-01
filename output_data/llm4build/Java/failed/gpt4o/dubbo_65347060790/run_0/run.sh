#!/bin/bash

# Set MAVEN_OPTS for JDK 24+
export MAVEN_OPTS="--sun-misc-unsafe-memory-access=allow"

# Set current date as env variable
export TODAY=$(date +'%Y%m%d')

# Run Maven tests
set -o pipefail
mvn $MAVEN_ARGS clean test verify -Pjacoco,jdk15ge-simple,'!jdk15ge-add-open',skip-spotless \
    -DtrimStackTrace=false -Dmaven.test.skip=false -Dcheckstyle.skip=false \
    -Dcheckstyle_unix.skip=false -Drat.skip=false \
    -DembeddedZookeeperPath=/app/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log)

# Print test error log if there is a failure
if [ $? -ne 0 ]; then
    cat test_errors.log
fi