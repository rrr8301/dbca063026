#!/bin/bash
set -e

# Build (skip tests in this step)
echo "Building project..."
mvn -T 1C -B clean install -DskipTests -Drat.skip=true -Dlicense.skip=true

# Run tests
echo "Running tests..."
mvn -T 1C -B test -Drat.skip=true -Dlicense.skip=true

echo "Build and tests completed successfully!"