#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "=========================================="
echo "Building Fluss - Java 11 / core"
echo "=========================================="

# Build phase
echo ""
echo "Step 1: Building project..."
mvn -T 1C -B clean install -DskipTests || {
    echo -e "${RED}Build failed${NC}"
    echo "FINAL_STATUS = FAIL"
    exit 1
}

# Test phase
echo ""
echo "Step 2: Running tests..."
mkdir -p /tmp/fluss-logs

# Get test modules for core stage
TEST_MODULES=$(./.github/workflows/stage.sh core)
echo "Test modules: $TEST_MODULES"

export MAVEN_OPTS="-Xmx4096m"

# Run tests
mvn -B verify $TEST_MODULES \
    -Ptest-coverage \
    -Ptest-core \
    -Dlog.dir=/tmp/fluss-logs \
    -Dlog4j.configurationFile=$(pwd)/tools/ci/log4j.properties

TEST_STATUS=$?

echo ""
echo "=========================================="
if [ $TEST_STATUS -eq 0 ]; then
    echo -e "${GREEN}Tests passed${NC}"
    echo "FINAL_STATUS = SUCCESS"
else
    echo -e "${RED}Tests failed${NC}"
    echo "FINAL_STATUS = FAIL"
fi
echo "=========================================="

exit $TEST_STATUS
