#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Test with Maven (clean package with tests on specific modules)
echo "Running Maven clean package with tests..."
./mvnw clean package -B -Dmaven.test.skip=false -pl fesod-common,fesod-shaded,fesod-sheet,fesod-examples/fesod-sheet-examples

# Maven Build (install)
echo "Running Maven install..."
./mvnw install -B -V

# JavaDoc generation
echo "Generating JavaDoc..."
./mvnw javadoc:javadoc

echo "All tests and builds completed successfully!"