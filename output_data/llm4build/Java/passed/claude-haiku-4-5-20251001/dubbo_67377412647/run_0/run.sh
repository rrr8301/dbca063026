#!/bin/bash

set -e

# Environment variables from GitHub Actions job
export FORK_COUNT=2
export FAIL_FAST=0
export SHOW_ERROR_DETAIL=1
export VERSIONS_LIMIT=4
export JACOCO_ENABLE=true
export CANDIDATE_VERSIONS='
    spring.version:5.3.24,6.1.5;
    spring-boot.version:2.7.6,3.2.3;
    '
export MAVEN_OPTS="-XX:+UseG1GC -XX:InitiatingHeapOccupancyPercent=45 -XX:+UseStringDeduplication -XX:-TieredCompilation -XX:TieredStopAtLevel=1 -Dmaven.javadoc.skip=true -Dmaven.wagon.http.retryHandler.count=5 -Dmaven.wagon.httpconnectionManager.ttlSeconds=120"
export MAVEN_ARGS="-e --batch-mode --no-snapshot-updates --no-transfer-progress --fail-fast"
export DISABLE_FILE_SYSTEM_TEST=true
export ZOOKEEPER_VERSION=3.7.2

# Set current date
export TODAY=$(date +'%Y%m%d')

# Create temporary directory for Zookeeper
mkdir -p .tmp/zookeeper

# Download Zookeeper if not already present
if [ ! -f ".tmp/zookeeper/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" ]; then
    echo "Downloading Zookeeper ${ZOOKEEPER_VERSION}..."
    wget -q -O ".tmp/zookeeper/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
        "https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" || \
    wget -q -O ".tmp/zookeeper/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" \
        "https://downloads.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"
fi

# Extract Zookeeper
if [ ! -d ".tmp/zookeeper/apache-zookeeper-${ZOOKEEPER_VERSION}-bin" ]; then
    echo "Extracting Zookeeper..."
    tar -xzf ".tmp/zookeeper/zookeeper-${ZOOKEEPER_VERSION}.tar.gz" -C ".tmp/zookeeper/"
fi

# Verify Java installation
echo "Java version:"
java -version

# Run Maven tests
echo "Running Maven tests..."
set -o pipefail

./mvnw $MAVEN_ARGS clean test verify \
    -Pjacoco,jdk15ge-simple,'!jdk15ge-add-open',skip-spotless \
    -DtrimStackTrace=false \
    -Dmaven.test.skip=false \
    -Dcheckstyle.skip=false \
    -Dcheckstyle_unix.skip=false \
    -Drat.skip=false \
    -DembeddedZookeeperPath=$(pwd)/.tmp/zookeeper 2>&1 | tee >(grep -n -B 1 -A 200 "FAILURE! -- in" > test_errors.log) || TEST_FAILED=1

# Print test error log if tests failed
if [ -f test_errors.log ] && [ -s test_errors.log ]; then
    echo ""
    echo "=== Test Error Log ==="
    cat test_errors.log
fi

# Exit with appropriate code
if [ "$TEST_FAILED" = "1" ]; then
    exit 1
fi

exit 0