#!/bin/bash

set -e

# Extract Node.js and Bun versions from .tool-versions if it exists
if [ -f .tool-versions ]; then
    NODE_VERSION=$(grep '^nodejs' .tool-versions | awk '{print $2}')
    BUN_VERSION=$(grep '^bun' .tool-versions | awk '{print $2}')
    
    if [ -n "$NODE_VERSION" ]; then
        echo "Installing Node.js version: $NODE_VERSION"
        # Note: Node.js is already installed in Dockerfile; version pinning would require nvm
    fi
    
    if [ -n "$BUN_VERSION" ]; then
        echo "Using Bun version: $BUN_VERSION"
        # Note: Bun is already installed in Dockerfile
    fi
fi

# Install project dependencies
echo "Installing dependencies with bun..."
bun install --frozen-lockfile

# Run format check
echo "Running format check..."
bun run format

# Run linter
echo "Running linter..."
bun run lint

# Run editorconfig checker
echo "Running editorconfig checker..."
bun run editorconfig-checker -format github-actions

# Build project
echo "Building project..."
bun run build

# Run tests
echo "Running tests..."
bun run test

echo "All checks and tests completed successfully!"