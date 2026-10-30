#!/bin/bash

set -e

# Check if repository is already mounted/copied (for Docker usage)
# If REPO_URL is provided, clone it; otherwise assume code is already in /workspace
if [ -n "$REPO_URL" ]; then
    if [ -z "$REPO_BRANCH" ]; then
        REPO_BRANCH="main"
    fi
    
    # Clone repository
    echo "Cloning repository from $REPO_URL (branch: $REPO_BRANCH)..."
    git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" /tmp/repo
    cd /tmp/repo
else
    # Assume code is already in /workspace or current directory
    echo "Using existing repository in current directory..."
    cd /workspace
fi

# Verify package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in $(pwd)"
    exit 1
fi

# Verify Node.js and Yarn installation
echo "Node.js version:"
node --version
echo "Yarn version:"
yarn --version

# Install dependencies with frozen lockfile
echo "Installing dependencies..."
yarn --frozen-lockfile

# Link yarn packages locally (only if package.json exists in current directory)
echo "Linking yarn packages..."
yarn link --frozen-lockfile || true

# Link webpack package
echo "Linking webpack..."
yarn link webpack --frozen-lockfile || true

# Run tests
echo "Running tests..."
yarn test:basic --ci

echo "Tests completed successfully!"