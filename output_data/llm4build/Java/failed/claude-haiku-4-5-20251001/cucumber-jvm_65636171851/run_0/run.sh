#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Install dependencies (resolve all dependencies, skip tests)
echo "Installing dependencies..."
mvn install \
  -Pinclude-extra-modules \
  -DskipTests=true \
  -DskipITs=true \
  -D"archetype.test.skip=true" \
  -D"maven.javadoc.skip=true" \
  --batch-mode \
  -D"style.color=always" \
  --show-version

# Run tests
echo "Running tests..."
mvn verify \
  -Pinclude-extra-modules \
  -D"style.color=always" \
  -Drat.skip=true \
  -Dlicense.skip=true