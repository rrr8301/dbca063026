#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Set environment variable to indicate we're running in a container
# This tells build-linux to skip sudo
export CONTAINER_ENV=true

# Run the build and test script
# This script handles generation, building, and testing
./build-scripts/build-linux

echo "Build and test completed successfully!"