#!/bin/bash

set -e

# Print Java version for verification
echo "Java version:"
java -version

echo "Maven version:"
mvn -version

# Check if pom.xml exists
if [ ! -f "pom.xml" ]; then
    echo "ERROR: pom.xml not found in /workspace"
    echo "Current directory: $(pwd)"
    echo "Directory contents:"
    ls -la
    exit 1
fi

echo "Repository found with pom.xml"

# Build with Maven
echo "Building with Maven..."
mvn -B package --file pom.xml -Dorg.slf4j.simpleLogger.defaultLogLevel=info

echo "Build completed successfully!"