#!/bin/bash

set -e

# Export required environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
echo "Building Radare2..."
cd /workspace
/workspace/sys/install.sh

# Run tests from the workspace directory where the build was configured
echo "Running tests..."
cd /workspace
make tests

echo "Tests completed successfully!"