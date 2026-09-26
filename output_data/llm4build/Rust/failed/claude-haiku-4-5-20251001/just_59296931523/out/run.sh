#!/bin/bash

set -e

# Print commands as they execute for debugging
set -x

# Ensure we're in the workspace directory
cd /workspace

# Run all tests
echo "Running cargo tests..."
cargo test --all

# Test install.sh script
echo "Testing install.sh script..."
bash www/install.sh --to /tmp --tag 1.25.0

# Verify the installed binary works
echo "Verifying installed just binary..."
/tmp/just --version

echo "All tests completed successfully!"