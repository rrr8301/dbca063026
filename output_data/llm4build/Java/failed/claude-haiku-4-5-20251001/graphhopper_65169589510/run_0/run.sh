#!/bin/bash

set -e

# Print Java version for verification
echo "Java version:"
java -version

# Print Maven version for verification
echo "Maven version:"
mvn -version

# Print Node.js version for verification
echo "Node.js version:"
node --version

# Print npm version for verification
echo "npm version:"
npm --version

# Run Maven clean test
echo "Running Maven build and tests..."
mvn -B clean test

echo "Build and tests completed successfully!"