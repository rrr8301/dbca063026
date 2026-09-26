#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies (skip tests and ITs)
echo "Installing dependencies..."
mvn install \
  -Pinclude-extra-modules \
  -DskipTests=true \
  -DskipITs=true \
  -D"archetype.test.skip=true" \
  -D"maven.javadoc.skip=true" \
  -Drat.skip=true \
  -Dlicense.skip=true \
  --batch-mode \
  -D"style.color=always" \
  --show-version

# Run tests
echo "Running tests..."
mvn verify \
  -Pinclude-extra-modules \
  -Drat.skip=true \
  -Dlicense.skip=true \
  -D"style.color=always"

echo "Build and tests completed successfully!"