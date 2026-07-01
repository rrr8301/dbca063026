#!/bin/bash

set -e

# Print environment info
echo "=== Build Environment ==="
java -version
echo "JAVA_HOME: $JAVA_HOME"
echo "JAVA_OPTS: $JAVA_OPTS"
echo ""

# Change to workspace
cd /workspace

# Build and test
echo "=== Building and Testing ==="
./mvnw -B -ff -ntp verify

# Extract project version
echo ""
echo "=== Extracting Project Version ==="
PROJECT_VERSION=$(./mvnw org.apache.maven.plugins:maven-help-plugin:3.5.1:evaluate -DforceStdout -Dexpression=project.version -q)
echo "Project Version: $PROJECT_VERSION"

echo ""
echo "=== Build Complete ==="