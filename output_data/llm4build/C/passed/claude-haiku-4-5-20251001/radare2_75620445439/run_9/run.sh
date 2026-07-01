#!/bin/bash

set -e

# Export required environment variables
export CFLAGS="-O2 -Wno-unused-result"
export LD_LIBRARY_PATH=/usr/local/lib

# Build Radare2
echo "Building Radare2..."
cd /workspace

# Run the install script which handles configure
echo "Running installation script..."
/workspace/sys/install.sh

echo "Configuration successful, running tests..."
cd /workspace
make tests

echo "Tests completed successfully!"