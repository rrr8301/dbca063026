#!/bin/bash

set -e

# Set environment variable for PyO3 ABI3 forward compatibility
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=""

# Ensure Python 3.14 is available
python3 --version

# Install project dependencies using make
echo "Installing dependencies..."
make

# Run tests using make ci
echo "Running tests..."
make ci

echo "All tests completed successfully!"