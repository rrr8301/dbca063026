#!/bin/bash
set -e

# Ensure we're in the workspace directory for all operations
cd /workspace

# Verify the repository structure exists
if [ ! -f "go.mod" ]; then
    echo "Error: go.mod not found in /workspace"
    exit 1
fi

# Run verify-generate which includes go generate
echo "Running verify-generate..."
if ! make verify-generate; then
    echo "verify-generate failed"
    exit 1
fi

# Run lint
echo "Running lint..."
if ! make lint; then
    echo "lint failed"
    exit 1
fi

# Run build
echo "Running build..."
if ! make build; then
    echo "build failed"
    exit 1
fi

# Run test with verbose output and proper error handling
echo "Running test..."
if ! make test; then
    echo "test failed"
    exit 1
fi

echo "All tasks completed successfully!"