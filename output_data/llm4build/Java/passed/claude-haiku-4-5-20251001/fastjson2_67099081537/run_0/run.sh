#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an argument or use current directory)
# If running in a pre-cloned repo, this step can be skipped
if [ ! -f "pom.xml" ]; then
    echo "Error: pom.xml not found. Please ensure the repository is cloned or mounted."
    exit 1
fi

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