#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
if [ -z "$REPO_URL" ]; then
    echo "Error: REPO_URL environment variable not set"
    exit 1
fi

if [ -z "$REPO_BRANCH" ]; then
    REPO_BRANCH="main"
fi

# Clone repository
git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" /tmp/repo
cd /tmp/repo

# Verify Node.js and Yarn installation
echo "Node.js version:"
node --version
echo "Yarn version:"
yarn --version

# Install dependencies with frozen lockfile
echo "Installing dependencies..."
yarn --frozen-lockfile

# Link yarn packages locally
echo "Linking yarn packages..."
yarn link --frozen-lockfile || true

# Link webpack package
echo "Linking webpack..."
yarn link webpack --frozen-lockfile

# Run tests
echo "Running tests..."
yarn test:basic --ci

echo "Tests completed successfully!"