#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Display Java version for debugging
echo "Java version:"
java -version

# Build and run tests
# Using Maven wrapper with the exact flags from the workflow
./mvnw clean install -T1C -B -ntp -fae -Drat.skip=true -Dlicense.skip=true

echo "Build and tests completed successfully!"