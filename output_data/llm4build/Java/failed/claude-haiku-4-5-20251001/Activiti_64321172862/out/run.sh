#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Display Java version
java -version

# Display Maven version
mvn -version

# Install project dependencies and run tests
# Using verify goal to run all tests without deploying
# MAVEN_CLI_OPTS includes standard options for CI environment
mvn verify \
  --show-version \
  --no-transfer-progress \
  -Drat.skip=true \
  -Dlicense.skip=true

# Echo longest tests run (informational)
echo "=== Longest Tests Run ==="
find . -name TEST-*.xml -exec grep -h testcase {} \; | awk -F '"' '{printf("%s#%s() - %.3f s\n", $4, $2, $6); }' | sort -n -k 3 | tail -20 || true

echo "=== Build and Tests Completed Successfully ==="