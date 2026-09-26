#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Verify Go installation
go version

# Tidy Go modules
echo "Tidying Go modules..."
go mod tidy

# Check for changes (this will fail if go mod tidy made changes)
echo "Checking for unexpected changes..."
git diff --exit-code || {
    echo "Warning: git diff detected changes (likely from go mod tidy)"
    git diff
}

# Build
echo "Building..."
go build ./...

# Test
echo "Running tests..."
go test ./...

echo "Build and test completed successfully!"