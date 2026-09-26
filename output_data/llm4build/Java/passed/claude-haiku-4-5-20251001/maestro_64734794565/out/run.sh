#!/bin/bash

set -e

# Navigate to workspace
cd /workspace

# Display Java version for debugging
echo "Java version:"
java -version

# Display Gradle version
echo "Gradle version:"
./gradlew --version

# Run Gradle build (exact command from YAML)
echo "Running Gradle build..."
./gradlew build

echo "Build completed successfully!"