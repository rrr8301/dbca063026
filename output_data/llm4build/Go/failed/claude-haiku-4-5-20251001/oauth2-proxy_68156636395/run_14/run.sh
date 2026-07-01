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
# Run from the workspace root where relative paths are correct
echo "Running verify-generate..."
GOWORK=off make verify-generate

# Run lint
echo "Running lint..."
GOWORK=off make lint

# Run build
echo "Running build..."
GOWORK=off make build

# Run test
echo "Running test..."
GOWORK=off make test

echo "All tasks completed successfully!"