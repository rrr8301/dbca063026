#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Prepare build directory
mkdir -p /app/build
cd /app/build

# Build the project
if [ -f /app/source/ci/build.sh ]; then
    bash /app/source/ci/build.sh
else
    echo "Build script not found: /app/source/ci/build.sh"
    exit 1
fi

# Test the project
if [ -f /app/source/ci/test.sh ]; then
    bash /app/source/ci/test.sh
else
    echo "Test script not found: /app/source/ci/test.sh"
    exit 1
fi