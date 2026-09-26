#!/bin/bash

set -e

# Export required environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
echo "Building Radare2..."
sys/install.sh

# Run tests
echo "Running tests..."
make tests

echo "Tests completed successfully!"