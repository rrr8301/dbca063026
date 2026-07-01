#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Display Java version for debugging
java -version
javac -version

# Run Maven verify with the specified arguments
./mvnw -B -V -ntp -e -Djansi.passthrough=true -Dstyle.color=always verify

echo "Build and tests completed successfully!"