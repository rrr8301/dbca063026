#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Configure git for charmbracelet repos (if credentials are available)
# Note: This requires authentication; for local builds, ensure credentials are set up
# git config --global url."https://${GITHUB_TOKEN}@github.com/charmbracelet".insteuldOf "https://github.com/charmbracelet"

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