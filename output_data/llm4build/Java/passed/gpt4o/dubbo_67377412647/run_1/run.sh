#!/bin/bash

# Activate environment variables
export MAVEN_OPTS="-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120"
export MAVEN_ARGS="-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast"

# Install project dependencies and run tests
set -o pipefail
./mvnw $MAVEN_ARGS clean test verify -Pjacoco,jdk15ge-simple,'!jdk15ge-add-open',skip-spotless -DtrimStackTrace=false -Dmaven.test.skip=false -Dcheckstyle.skip=false -Dcheckstyle_unix.skip=false -Drat.skip=false -DembeddedZookeeperPath=/app/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log)

# Print test error log if any
if [ -s test_errors.log ]; then
  cat test_errors.log
fi