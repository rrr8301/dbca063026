#!/bin/bash

set -e

# Determine the repository root
# The repo should be mounted/checked out to /workspace
REPO_ROOT="/workspace"

# Verify that the repository structure exists
if [ ! -d "$REPO_ROOT/lib" ]; then
    echo "Error: Repository structure not found at $REPO_ROOT"
    echo "Expected to find lib/, bin/, site/, test/ directories"
    exit 1
fi

echo "Building in: $REPO_ROOT"

# Navigate to the repository root
cd "$REPO_ROOT"

# Configure the library
# Note: --enable-mps is macOS-specific and will be skipped on Linux
echo "Configuring library..."
cd "$REPO_ROOT/lib"
if ./configure --enable-mps 2>&1 | grep -q "unrecognized option"; then
    echo "Warning: --enable-mps not supported on this platform, reconfiguring without it..."
    ./configure
else
    ./configure --enable-mps
fi
cd "$REPO_ROOT"

# Build lib
echo "Building lib..."
make -C lib lib || { echo "lib build failed"; exit 1; }

# Build bin
echo "Building bin..."
make -C bin || { echo "bin build failed"; exit 1; }

# Build site source
echo "Building site source..."
make -C site source || { echo "site source build failed"; exit 1; }

# Build test
echo "Building test..."
make -C test || { echo "test build failed"; exit 1; }

# Run tests
echo "Running tests..."
make -C test test || { echo "test execution failed"; exit 1; }

echo "All builds and tests completed successfully!"