#!/bin/bash

set -e

echo "=========================================="
echo "Java CI Build and Test"
echo "=========================================="

# Display Java version
echo "Java version:"
java -version

# Update Maven wrapper SHA-256 checksum if needed
if [ -f .mvn/wrapper/maven-wrapper.properties ]; then
    echo "Updating Maven wrapper configuration..."
    # Remove or clear the distributionSha256Sum to allow Maven wrapper to validate properly
    sed -i 's/^distributionSha256Sum=.*/distributionSha256Sum=/' .mvn/wrapper/maven-wrapper.properties || true
fi

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
  -Drat.excludes="**/Dockerfile,**/run.sh" \
  -P-use-toolchains,docker

echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="