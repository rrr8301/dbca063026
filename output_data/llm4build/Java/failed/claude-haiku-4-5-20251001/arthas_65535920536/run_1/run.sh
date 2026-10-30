#!/bin/bash

set -e

# Print Java and Maven versions for debugging
echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -version

# Navigate to workspace
cd /workspace

# Build with Maven (matching the GitHub Actions job)
echo "=== Building with Maven ==="
mvn -V -ntp clean install -P full verify

echo "=== Build completed successfully ==="