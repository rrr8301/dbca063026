#!/bin/bash

set -e

# Print commands for debugging
set -x

# Change to workspace directory
cd /workspace

# Install dependencies using nci (from @antfu/ni)
nci

# Install Playwright browsers with system dependencies
pnpm exec playwright install --with-deps

# Build the project
nr build

# Typecheck
nr typecheck

# Run unit tests with coverage
echo "Running unit tests with coverage..."
pnpm run test:cov || TEST_COV_FAILED=1

# Run browser tests
echo "Running browser tests..."
pnpm run test:browser || TEST_BROWSER_FAILED=1

# Run server tests
echo "Running server tests..."
pnpm run test:server || TEST_SERVER_FAILED=1

# Run attw tests
echo "Running attw tests..."
pnpm run test:attw || TEST_ATTW_FAILED=1

# Report test results
echo ""
echo "========== TEST SUMMARY =========="
FAILED=0

if [ "$TEST_COV_FAILED" = "1" ]; then
    echo "❌ Unit tests with coverage FAILED"
    FAILED=1
else
    echo "✅ Unit tests with coverage PASSED"
fi

if [ "$TEST_BROWSER_FAILED" = "1" ]; then
    echo "❌ Browser tests FAILED"
    FAILED=1
else
    echo "✅ Browser tests PASSED"
fi

if [ "$TEST_SERVER_FAILED" = "1" ]; then
    echo "❌ Server tests FAILED"
    FAILED=1
else
    echo "✅ Server tests PASSED"
fi

if [ "$TEST_ATTW_FAILED" = "1" ]; then
    echo "❌ ATTW tests FAILED"
    FAILED=1
else
    echo "✅ ATTW tests PASSED"
fi

echo "=================================="

exit $FAILED