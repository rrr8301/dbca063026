#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run the build and test script
# This script handles generation, building, and testing
# Remove sudo since we're already running as root in the container
./build-scripts/build-linux

echo "Build and test completed successfully!"