#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Display Java version
java -version

# Display Maven version
mvn -v

# Build with Maven using the exact command from the workflow
# This includes running tests as part of the package goal
mvn --no-transfer-progress -Dfastjson2.creator=reflect -Drat.skip=true -Dlicense.skip=true clean package

echo "Build and tests completed successfully!"