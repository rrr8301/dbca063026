#!/bin/bash

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the script directory (workspace root)
cd "$SCRIPT_DIR"

# Check if pom.xml exists in current directory or parent directories
if [ ! -f "pom.xml" ]; then
    echo "Error: pom.xml not found in $SCRIPT_DIR. Please ensure the repository is cloned or mounted."
    exit 1
fi

echo "=========================================="
echo "Current Working Directory:"
pwd
echo "=========================================="

echo "=========================================="
echo "Java Version:"
java -version
echo "=========================================="

echo "=========================================="
echo "Maven Wrapper Version:"
./mvnw -v
echo "=========================================="

echo "=========================================="
echo "Building and testing core3 module..."
echo "=========================================="

# Run the Maven build and test command
# -V: Show version
# --no-transfer-progress: Suppress transfer progress
# -pl core3: Build only core3 module
# -am: Also make dependencies
# clean package: Clean and package
./mvnw -V --no-transfer-progress -pl core3 -am clean package

echo "=========================================="
echo "Build and test completed successfully!"
echo "=========================================="

exit 0