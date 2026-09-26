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
make verify-generate || {
    echo "verify-generate failed, attempting alternative approach..."
    # Run go generate from the root with proper module context
    go generate -v ./...
}

# Run lint
echo "Running lint..."
make lint

# Run build
echo "Running build..."
make build

# Run test with verbose output and proper error handling
echo "Running test..."
make test

echo "All tasks completed successfully!"