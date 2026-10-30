#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Display Java version for debugging
java -version
javac -version

# Display Maven version for debugging
mvn -version

# Run Maven verify with the specified arguments
mvn -B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always -Drat.skip=true -Dlicense.skip=true verify

echo "Build and tests completed successfully!"