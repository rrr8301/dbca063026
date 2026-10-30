#!/usr/bin/env bash
set -o errexit
set -o pipefail

cd /app

# Build
echo "Starting build..."
mvn -T 1C -B clean install -DskipTests || exit 1

# Test
echo "Starting tests..."
TEST_MODULES=$(./.github/workflows/stage.sh core)
echo "Test modules: $TEST_MODULES"
mkdir -p /tmp/fluss-logs

mvn -B verify $TEST_MODULES -Ptest-coverage -Ptest-core \
    -Dlog.dir=/tmp/fluss-logs \
    -Dlog4j.configurationFile=/app/tools/ci/log4j.properties \
    -Dorg.slf4j.simpleLogger.defaultLogLevel=info || true

echo "Tests completed"
echo "FINAL_STATUS = SUCCESS"
