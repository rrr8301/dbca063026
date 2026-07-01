#!/bin/bash
set -e

# Verify that the repository is mounted or copied into /workspace
if [ ! -f "/workspace/package.json" ]; then
    echo "Error: /workspace/package.json not found"
    echo "Please mount or copy the repository into /workspace"
    echo "Usage: docker run -v /path/to/repo:/workspace <image-name>"
    exit 1
fi

cd /workspace

# Verify required files exist
if [ ! -f "/workspace/pnpm-lock.yaml" ]; then
    echo "Error: /workspace/pnpm-lock.yaml not found"
    exit 1
fi

if [ ! -f "/workspace/pnpm-workspace.yaml" ]; then
    echo "Error: /workspace/pnpm-workspace.yaml not found"
    exit 1
fi

# Install project dependencies
echo "Installing dependencies..."
pnpm install --prod false --frozen-lockfile

# Build cli package
echo "Building cli package..."
cd /workspace/packages/cli
pnpm build

# Build eslint-parser package
echo "Building eslint-parser package..."
cd /workspace/packages/eslint-parser
pnpm build

# Run tests
echo "Running tests..."
cd /workspace
pnpm test

echo "All tasks completed successfully!"