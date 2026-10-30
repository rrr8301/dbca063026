#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Run all tests
echo "Running cargo test --all..."
cargo test --all

# Test install.sh
echo "Testing install.sh..."
bash www/install.sh --to /tmp --tag 1.25.0

# Verify the installed binary
echo "Verifying installed just binary..."
/tmp/just --version

echo "All tests passed!"