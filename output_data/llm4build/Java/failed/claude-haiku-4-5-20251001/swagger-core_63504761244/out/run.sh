#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Build with Maven (includes tests)
echo "Building with Maven..."
./mvnw --no-transfer-progress -B install --file pom.xml

# Build with Gradle (includes tests)
echo "Building Gradle plugin..."
cd ./modules/swagger-gradle-plugin
./gradlew build --info
cd ../..

echo "Build and tests completed successfully!"