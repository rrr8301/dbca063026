#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, the repo is typically mounted or copied
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
fi

cd /workspace

# Install dependencies using npm ci (clean install with lock file)
echo "Installing dependencies..."
npm ci

# Run tests with coverage and CI flag
echo "Running tests with coverage..."
npm run test:coverage -- --ci

echo "Tests completed successfully!"