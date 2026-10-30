#!/bin/bash

set -e

# Print Java version for debugging
echo "Java version:"
java -version

# Print Maven version for debugging
echo "Maven version:"
mvn -version

# Print Node version for debugging
echo "Node version:"
node --version
npm --version

# Change to workspace directory
cd /workspace

# Run Maven build and test
# -B: batch mode (non-interactive)
# clean: remove previous build artifacts
# test: compile and run tests
echo "Starting Maven build and test..."
mvn -B clean test

echo "Build and test completed successfully!"