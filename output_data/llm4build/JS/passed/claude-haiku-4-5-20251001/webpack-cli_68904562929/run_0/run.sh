#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
if [ -z "$REPO_URL" ]; then
    echo "Error: REPO_URL environment variable not set"
    exit 1
fi

if [ -z "$REPO_REF" ]; then
    REPO_REF="main"
fi

# Clone repository
git clone --depth 1 --branch "$REPO_REF" "$REPO_URL" /tmp/repo
cd /tmp/repo

# Display Node.js and npm versions
echo "Node.js version:"
node --version
echo "npm version:"
npm --version
echo "pnpm version:"
pnpm --version

# Install dependencies (npm ci with ignore-scripts)
echo "Installing dependencies..."
npm ci --ignore-scripts

# Prepare environment for tests (build with sourceMap)
echo "Building project..."
npm run build -- --sourceMap true

# Run tests and generate coverage
echo "Running tests with coverage..."
npm run test:coverage -- --ci

echo "All tests completed successfully!"