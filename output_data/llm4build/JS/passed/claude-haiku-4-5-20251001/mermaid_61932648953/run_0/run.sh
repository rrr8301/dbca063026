#!/bin/bash

set -e

# Enable error handling - continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Mermaid Unit Tests"
echo "=========================================="

# Step 1: Install dependencies
echo ""
echo "Step 1: Installing dependencies with pnpm..."
pnpm install --frozen-lockfile
export CYPRESS_CACHE_FOLDER=.cache/Cypress

# Step 2: Run unit tests with coverage
echo ""
echo "Step 2: Running unit tests with coverage..."
if ! pnpm test:coverage; then
    echo "⚠️  Unit tests failed"
    TEST_FAILED=1
fi

# Step 3: Run ganttDb tests with California timezone
echo ""
echo "Step 3: Running ganttDb tests with California timezone..."
export TZ=America/Los_Angeles
if ! pnpm exec vitest run ./packages/mermaid/src/diagrams/gantt/ganttDb.spec.ts --coverage; then
    echo "⚠️  ganttDb tests failed"
    TEST_FAILED=1
fi

# Step 4: Verify out-of-tree build with TypeScript
echo ""
echo "Step 4: Verifying TypeScript build..."
if ! pnpm test:check:tsc; then
    echo "⚠️  TypeScript verification failed"
    TEST_FAILED=1
fi

# Summary
echo ""
echo "=========================================="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✅ All tests passed!"
    echo "=========================================="
    exit 0
else
    echo "❌ Some tests failed (see above for details)"
    echo "=========================================="
    exit 1
fi