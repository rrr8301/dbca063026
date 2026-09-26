#!/bin/bash
set -e

# Print Node.js and npm versions for debugging
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install dependencies
echo "Installing dependencies..."
npm ci

# Build client dependencies
echo "Building client dependencies..."
npm run build:client

# Run protocol tests
echo "Running protocol tests..."
npm run test --workspace=@getpaseo/protocol || TEST_PROTOCOL_FAILED=1

# Run client tests
echo "Running client tests..."
npm run test --workspace=@getpaseo/client || TEST_CLIENT_FAILED=1

# Typecheck client examples
echo "Typechecking client examples..."
npm run typecheck:examples --workspace=@getpaseo/client || TEST_TYPECHECK_FAILED=1

# Report test results
if [ -n "$TEST_PROTOCOL_FAILED" ] || [ -n "$TEST_CLIENT_FAILED" ] || [ -n "$TEST_TYPECHECK_FAILED" ]; then
    echo "Some tests failed!"
    exit 1
fi

echo "All tests passed!"
exit 0