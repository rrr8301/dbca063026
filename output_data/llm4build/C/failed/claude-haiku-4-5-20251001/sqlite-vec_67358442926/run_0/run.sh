#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run vendor script
echo "Running vendor script..."
./scripts/vendor.sh

# Build loadable and static extensions
echo "Building loadable and static extensions..."
make loadable static

# Sync Python test dependencies
echo "Syncing test dependencies with uv..."
uv sync --directory tests

# Run tests
echo "Running tests..."
make test-loadable

echo "All tests completed successfully!"