#!/bin/bash

set -e

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, assume the repo is already mounted or copied
if [ ! -d ".git" ]; then
    echo "Repository not found. Assuming code is already in /workspace"
fi

# Install Node dependencies
echo "Installing Node dependencies..."
npm ci

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