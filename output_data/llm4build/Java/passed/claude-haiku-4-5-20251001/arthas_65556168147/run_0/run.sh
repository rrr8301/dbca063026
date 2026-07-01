#!/bin/bash
set -e

# Print environment info
echo "=== Java Version ==="
java -version

echo "=== Maven Version ==="
mvn -v

echo "=== Node.js Version ==="
node --version

echo "=== Yarn Version ==="
yarn --version

# Navigate to workspace
cd /workspace

# Run Maven build with full profile and verification
echo "=== Building with Maven ==="
mvn -V -ntp clean install -P full verify

echo "=== Build completed successfully ==="