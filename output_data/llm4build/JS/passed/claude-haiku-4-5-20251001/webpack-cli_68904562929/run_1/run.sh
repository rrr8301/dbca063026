#!/bin/bash

set -e

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

# Upload coverage to Codecov (if token is available)
if [ -n "$CODECOV_TOKEN" ]; then
    echo "Uploading coverage to Codecov..."
    # Note: Codecov upload would typically be handled by the codecov-action in GitHub Actions
    # For Docker execution, you may need to install and run codecov CLI separately
fi

echo "All tests completed successfully!"