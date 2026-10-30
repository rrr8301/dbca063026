#!/bin/bash

set -e

echo "=========================================="
echo "Java CI Build and Test"
echo "=========================================="

# Display Java version
echo "Java version:"
java -version

# Display Maven version (via wrapper)
echo "Maven version:"
./mvnw -v

# Build with Maven
echo "Building with Maven..."
./mvnw -V \
  --file pom.xml \
  --no-transfer-progress \
  -DtrimStackTrace=false \
  -Djunit.jupiter.execution.parallel.enabled=false \
  -P-use-toolchains,docker

echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="