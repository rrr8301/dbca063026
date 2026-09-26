#!/bin/bash

set -e

echo "=========================================="
echo "Building Swagger Core with Maven and Gradle"
echo "=========================================="

# Verify Java installation
echo "Java version:"
java -version

# Build with Maven
echo ""
echo "=========================================="
echo "Building with Maven..."
echo "=========================================="
./mvnw --no-transfer-progress -B install --file pom.xml

# Build Gradle plugin
echo ""
echo "=========================================="
echo "Building Gradle plugin..."
echo "=========================================="
cd ./modules/swagger-gradle-plugin
./gradlew build --info
cd ../..

echo ""
echo "=========================================="
echo "Build completed successfully!"
echo "=========================================="