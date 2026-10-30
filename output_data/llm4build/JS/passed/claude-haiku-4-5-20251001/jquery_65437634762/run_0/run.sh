#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, the repo should be mounted or copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
fi

# Navigate to the jquery directory if it exists, otherwise stay in workspace
if [ -d "jquery" ]; then
    cd jquery
fi

echo "Node.js version:"
node --version

echo "npm version:"
npm --version

echo "Installing dependencies..."
npm ci

echo "Running browserless tests..."
npm run test:browserless

echo "All tests completed!"