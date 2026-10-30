#!/bin/bash

set -e

# Enable error handling - continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Installing dependencies with pnpm..."
echo "=========================================="
pnpm install --frozen-lockfile
export CYPRESS_CACHE_FOLDER=.cache/Cypress

echo ""
echo "=========================================="
echo "Running unit tests with coverage..."
echo "=========================================="
if ! pnpm test:coverage; then
    echo "Unit tests failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Running ganttDb tests with America/Los_Angeles timezone..."
echo "=========================================="
export TZ=America/Los_Angeles
if ! pnpm exec vitest run ./packages/mermaid/src/diagrams/gantt/ganttDb.spec.ts --coverage; then
    echo "ganttDb tests failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Verifying out-of-tree build with TypeScript..."
echo "=========================================="
if ! pnpm test:check:tsc; then
    echo "TypeScript check failed"
    TEST_FAILED=1
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed. See output above for details."
    exit 1
fi