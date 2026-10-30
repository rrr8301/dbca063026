#!/usr/bin/env bash

set -e

cd /app

echo "Setting up environment..."
export TODAY=$(date +'%Y%m%d')
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64

echo "Java version:"
java -version

echo "Maven version:"
./mvnw --version

echo "Running tests with Maven on Java 21..."

set -o pipefail
./mvnw $MAVEN_ARGS clean test verify -Pjacoco,jdk15ge-simple,'!jdk15ge-add-open',skip-spotless -DtrimStackTrace=false -Dmaven.test.skip=false -Dcheckstyle.skip=false -Dcheckstyle_unix.skip=false -Drat.skip=false -DembeddedZookeeperPath=/app/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log) || TEST_FAILED=true

if [ "$TEST_FAILED" = "true" ]; then
  echo "=== Test Errors ==="
  cat test_errors.log || true
  echo "FINAL_STATUS = FAIL"
  exit 1
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
