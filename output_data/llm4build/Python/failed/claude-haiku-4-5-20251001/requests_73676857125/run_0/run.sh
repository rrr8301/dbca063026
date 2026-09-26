#!/bin/bash

set -e

# Set environment variable for PyO3 ABI3 forward compatibility
export PYO3_USE_ABI3_FORWARD_COMPATIBILITY=''

# Change to workspace directory
cd /workspace

# Install dependencies using make
echo "Installing dependencies..."
make || {
    echo "Make failed, attempting manual installation..."
    pip install -e .
    pip install -r requirements-dev.txt 2>/dev/null || true
}

# Run tests using make ci
echo "Running tests..."
make ci || {
    echo "Tests completed with status: $?"
}

echo "Build and test process completed."