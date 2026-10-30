#!/bin/bash

set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

echo "=========================================="
echo "Node.js CI Build and Test"
echo "=========================================="

# Display Node.js and npm versions
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install dependencies
echo ""
echo "=========================================="
echo "Installing dependencies..."
echo "=========================================="
npm ci

# Lint code
echo ""
echo "=========================================="
echo "Linting code..."
echo "=========================================="
npm run lint || TEST_FAILED=1

# Run tests
echo ""
echo "=========================================="
echo "Running tests..."
echo "=========================================="
CI=true npm test || TEST_FAILED=1

# Build project
echo ""
echo "=========================================="
echo "Building swagger-js..."
echo "=========================================="
npm run build || TEST_FAILED=1

# Summary
echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All steps completed successfully"
    exit 0
else
    echo "✗ Some steps failed (see output above)"
    exit 1
fi