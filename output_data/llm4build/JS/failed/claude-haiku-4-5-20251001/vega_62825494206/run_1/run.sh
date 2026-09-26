#!/bin/bash

set -e

# Print Node and npm versions for debugging
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"

# Install Node dependencies using npm ci (clean install from package-lock.json)
echo "Installing Node dependencies..."
npm ci

# Run tests (no lint)
echo "Running tests..."
npm run test:no-lint
TEST_RESULT=$?

# Run typecheck
echo "Running typecheck..."
npm run typecheck
TYPECHECK_RESULT=$?

# Run lint
echo "Running lint..."
npm run lint
LINT_RESULT=$?

# Report results
echo ""
echo "========== Test Results =========="
echo "Tests (test:no-lint): $([ $TEST_RESULT -eq 0 ] && echo 'PASSED' || echo 'FAILED')"
echo "Typecheck: $([ $TYPECHECK_RESULT -eq 0 ] && echo 'PASSED' || echo 'FAILED')"
echo "Lint: $([ $LINT_RESULT -eq 0 ] && echo 'PASSED' || echo 'FAILED')"
echo "=================================="

# Exit with failure if any step failed
if [ $TEST_RESULT -ne 0 ] || [ $TYPECHECK_RESULT -ne 0 ] || [ $LINT_RESULT -ne 0 ]; then
    exit 1
fi

exit 0