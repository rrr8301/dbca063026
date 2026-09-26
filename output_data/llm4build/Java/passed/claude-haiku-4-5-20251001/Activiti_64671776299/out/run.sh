#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Display Java and Maven versions
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn -version
echo ""

# Build and test with Maven
# Using 'verify' phase to run tests without deployment
# MAVEN_CLI_OPTS from the workflow: --show-version --no-transfer-progress --settings settings.xml
echo "Running Maven build and tests..."
mvn verify \
  --show-version \
  --no-transfer-progress \
  --settings settings.xml \
  -Drat.skip=true \
  -Dlicense.skip=true

# Echo longest tests run
echo ""
echo "=== Longest Tests Run ==="
find . -name TEST-*.xml -exec grep -h testcase {} \; | awk -F '"' '{printf("%s#%s() - %.3f s\n", $4, $2, $6); }' | sort -n -k 3 | tail -20 || true

echo ""
echo "Build and tests completed successfully!"