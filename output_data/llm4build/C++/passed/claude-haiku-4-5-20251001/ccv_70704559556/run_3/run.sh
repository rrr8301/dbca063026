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

# Detect if we're on macOS or Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    echo "Detected macOS, configuring with --enable-mps..."
    ./configure --enable-mps
else
    # Linux and other platforms
    echo "Detected non-macOS platform, configuring without --enable-mps..."
    ./configure
fi

cd "$REPO_ROOT"

# Build lib
echo "Building lib..."
make -C lib lib CC=gcc || { echo "lib build failed"; exit 1; }

# Build bin
echo "Building bin..."
make -C bin CC=gcc || { echo "bin build failed"; exit 1; }

# Build site source
echo "Building site source..."
make -C site source CC=gcc || { echo "site source build failed"; exit 1; }

# Build test
echo "Building test..."
make -C test CC=gcc || { echo "test build failed"; exit 1; }

# Run tests
echo "Running tests..."
make -C test test CC=gcc || { echo "test execution failed"; exit 1; }

echo "All builds and tests completed successfully!"