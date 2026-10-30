#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Prepare build directory
mkdir -p build

# Build the project
cd build
if [ -f /app/source/ci/build.sh ]; then
    /app/source/ci/build.sh
else
    echo "Build script not found: /app/source/ci/build.sh"
    exit 1
fi

# Test the project
if [ -f /app/source/ci/test.sh ]; then
    /app/source/ci/test.sh
else
    echo "Test script not found: /app/source/ci/test.sh"
    exit 1
fi