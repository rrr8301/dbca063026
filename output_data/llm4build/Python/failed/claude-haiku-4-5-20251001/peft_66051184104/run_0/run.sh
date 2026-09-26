#!/bin/bash

set -e

# Set environment variables for testing
export HF_HOME=.cache/huggingface
export HF_TOKEN="${HF_TOKEN:-}"  # Placeholder for secret
export TRANSFORMERS_IS_CI=1
export CI=1

# Navigate to workspace
cd /workspace

# Run tests using make
echo "Running tests with make test..."
make test

# Clean up pytest temporary directories to free space
echo "Cleaning up pytest temporary directories..."
(rm -r "/tmp/pytest-of-$(id -u -n)" || true)

echo "Tests completed successfully!"