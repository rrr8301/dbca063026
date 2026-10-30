#!/bin/bash

set -e

# Configuration parameters (can be overridden via environment variables)
BOLT=${BOLT:-false}
FREE_THREADING=${FREE_THREADING:-false}

echo "=========================================="
echo "CPython Build and Test Configuration"
echo "=========================================="
echo "BOLT: $BOLT"
echo "FREE_THREADING: $FREE_THREADING"
echo "=========================================="

# Build configuration flags
CONFIG_FLAGS="--config-cache --with-pydebug"

if [ "$BOLT" = "true" ]; then
    CONFIG_FLAGS="$CONFIG_FLAGS --enable-bolt"
fi

if [ "$FREE_THREADING" = "true" ]; then
    CONFIG_FLAGS="$CONFIG_FLAGS --disable-gil"
fi

echo "Configure flags: $CONFIG_FLAGS"

# Clean previous builds if any
if [ -f Makefile ]; then
    echo "Cleaning previous build..."
    make clean || true
fi

# Configure CPython
echo "Configuring CPython..."
./configure $CONFIG_FLAGS

# Build CPython
echo "Building CPython (using 4 parallel jobs)..."
make -j4

# Display build info
echo "=========================================="
echo "Build Information"
echo "=========================================="
make pythoninfo

# Run tests
echo "=========================================="
echo "Running Tests"
echo "=========================================="
xvfb-run make ci

echo "=========================================="
echo "Build and Tests Completed Successfully"
echo "=========================================="