#!/bin/bash

set -e

# Enable error handling but continue on test failures
trap 'TEST_FAILED=1' ERR

TEST_FAILED=0

echo "=========================================="
echo "Installing dependencies with pnpm..."
echo "=========================================="
pnpm install

echo "=========================================="
echo "Adding TypeScript 5.5..."
echo "=========================================="
pnpm add typescript@5.5 -w

echo "=========================================="
echo "Building project..."
echo "=========================================="
pnpm build

echo "=========================================="
echo "Running main tests..."
echo "=========================================="
pnpm test || TEST_FAILED=1

echo "=========================================="
echo "Running @zod/resolution tests..."
echo "=========================================="
pnpm run --filter @zod/resolution test:all || TEST_FAILED=1

echo "=========================================="
echo "Running @zod/integration tests..."
echo "=========================================="
pnpm run --filter @zod/integration test:all || TEST_FAILED=1

echo "=========================================="
echo "Test execution completed"
echo "=========================================="

if [ $TEST_FAILED -eq 1 ]; then
    echo "Some tests failed, but all test suites were executed."
    exit 1
fi

exit 0