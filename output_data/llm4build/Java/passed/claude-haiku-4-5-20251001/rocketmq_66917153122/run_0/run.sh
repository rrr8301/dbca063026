#!/bin/bash

set -e

# Print Java version for verification
echo "Java version:"
java -version

echo "Maven version:"
mvn -version

# Clone or assume repository is already present
# If running in CI/CD, the repo should be mounted or cloned
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming it will be mounted or cloned externally."
fi

# Build with Maven
echo "Building with Maven..."
mvn -B package --file pom.xml

echo "Build completed successfully!"