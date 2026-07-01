#!/bin/bash

set -e

# Initialize rbenv for the testuser
eval "$(rbenv init - bash)"

# Print environment info
echo "=== Environment Info ==="
echo "Java version:"
java -version
echo ""
echo "Maven version:"
mvn -version
echo ""
echo "Python version:"
python3 --version
echo ""
echo "Node version:"
node --version
echo ""
echo "Ruby version:"
ruby --version
echo ""

# Navigate to workspace
cd /workspace

# Ensure a clean state without storm artifacts
echo "=== Cleaning Maven Repository ==="
rm -rf ~/.m2/repository/org/apache/storm

# Set up project dependencies
echo "=== Setting up Project Dependencies ==="
/bin/bash ./dev-tools/gitact/gitact-install.sh "$(pwd)"

# Run build
echo "=== Running Build ==="
export JDK_VERSION=17
export USER=github
/bin/bash ./dev-tools/gitact/gitact-script.sh "$(pwd)" Core

echo "=== Build Complete ==="