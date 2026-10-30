#!/bin/bash

set -e

# Verify we're in the workspace with project files
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in /workspace"
    exit 1
fi

# Install Node dependencies
echo "Installing Node dependencies..."
if [ -f "package-lock.json" ]; then
    npm ci
else
    echo "Warning: package-lock.json not found, using npm install instead"
    npm install
fi

# Run tests
echo "Running tests..."
npm run test:no-lint || TEST_FAILED=1

# Run typecheck
echo "Running typecheck..."
npm run typecheck || TYPECHECK_FAILED=1

# Run lint
echo "Running lint..."
npm run lint || LINT_FAILED=1

# Report results
echo ""
echo "========== Test Summary =========="
if [ -z "$TEST_FAILED" ]; then
    echo "✓ Tests passed"
else
    echo "✗ Tests failed"
fi

if [ -z "$TYPECHECK_FAILED" ]; then
    echo "✓ Typecheck passed"
else
    echo "✗ Typecheck failed"
fi

if [ -z "$LINT_FAILED" ]; then
    echo "✓ Lint passed"
else
    echo "✗ Lint failed"
fi

# Exit with failure if any step failed
if [ -n "$TEST_FAILED" ] || [ -n "$TYPECHECK_FAILED" ] || [ -n "$LINT_FAILED" ]; then
    exit 1
fi

exit 0