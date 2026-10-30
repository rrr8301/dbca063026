#!/bin/bash

set -e

# Export required environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
echo "Building Radare2..."
cd /workspace

# Run the install script which handles configure
/workspace/sys/install.sh

# Build the project
echo "Compiling Radare2..."
make

# Verify build artifacts exist
if [ ! -f /workspace/libr/config.mk ]; then
    echo "Error: Build configuration not found at /workspace/libr/config.mk"
    exit 1
fi

# Run tests from the workspace directory where the build was configured
echo "Running tests..."
cd /workspace
make tests

echo "Tests completed successfully!"