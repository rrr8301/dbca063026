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

echo "=== JAVA_HOME ==="
echo $JAVA_HOME

# Navigate to workspace
cd /workspace

# Run Maven build with full profile and verification
echo "=== Building with Maven ==="
mvn -V -ntp clean install -P full verify -Drat.skip=true -Dlicense.skip=true

echo "=== Build completed successfully ==="