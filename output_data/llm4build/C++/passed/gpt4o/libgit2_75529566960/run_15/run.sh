#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Prepare build directory
mkdir -p /app/build
cd /app/build

# Check if the build script exists and is executable
if [ -f /app/source/ci/build.sh ]; then
    chmod +x /app/source/ci/build.sh
    bash /app/source/ci/build.sh
else
    echo "Build script not found: /app/source/ci/build.sh"
    exit 1
fi

# Check if the test script exists and is executable
if [ -f /app/source/ci/test.sh ]; then
    chmod +x /app/source/ci/test.sh
    bash /app/source/ci/test.sh
else
    echo "Test script not found: /app/source/ci/test.sh"
    exit 1
fi