#!/bin/bash

set -e

# Set environment variables from the job
export FORK_COUNT=2
export FAIL_FAST=0
export SHOW_ERROR_DETAIL=1
export VERSIONS_LIMIT=4
export JACOCO_ENABLE=true
export CANDIDATE_VERSIONS='
    spring.version:5.3.24,6.1.5;
    spring-boot.version:2.7.6,3.2.3;
    '
export MAVEN_OPTS="--sun-misc-unsafe-memory-access=allow -XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120"
export MAVEN_ARGS="-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast"
export DISABLE_FILE_SYSTEM_TEST=true
export ZOOKEEPER_VERSION=3.7.2

# Set current date as env variable
export TODAY=$(date +'%Y%m%d')

# Create temporary directory for Zookeeper if it doesn't exist
mkdir -p /workspace/.tmp/zookeeper

# Verify Java installation
java -version

# Run Maven tests with the exact command from the YAML
set +e
./mvnw $MAVEN_ARGS clean test verify -Pjacoco,jdk15ge-simple,'!jdk15ge-add-open',skip-spotless -DtrimStackTrace=false -Dmaven.test.skip=false -Dcheckstyle.skip=false -Dcheckstyle_unix.skip=false -Drat.skip=false -DembeddedZookeeperPath=/workspace/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log)
TEST_EXIT_CODE=$?
set -e

# Print test error log if tests failed
if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "=== Test Error Log ==="
    if [ -f test_errors.log ]; then
        cat test_errors.log
    fi
fi

exit $TEST_EXIT_CODE