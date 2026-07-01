#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=========================================="
echo "Starting Web Test Suite"
echo "=========================================="

# Navigate to web directory
cd /workspace/web

echo ""
echo "========== Step 1: Setup TypeScript SDK =========="
cd /workspace/open-api/typescript-sdk
pnpm install --frozen-lockfile || TEST_FAILED=$?
pnpm build || TEST_FAILED=$?
cd /workspace/web

echo ""
echo "========== Step 2: Install Web Dependencies =========="
pnpm rebuild || TEST_FAILED=$?
pnpm install --frozen-lockfile || TEST_FAILED=$?

echo ""
echo "========== Step 3: Run TypeScript Type Checking =========="
pnpm check:typescript || TEST_FAILED=$?

echo ""
echo "========== Step 4: Run Unit Tests & Coverage =========="
pnpm test || TEST_FAILED=$?

echo ""
echo "=========================================="
echo "Web Test Suite Complete"
echo "=========================================="

if [ $TEST_FAILED -ne 0 ]; then
    echo "⚠️  Some tests failed. Exit code: $TEST_FAILED"
    exit $TEST_FAILED
else
    echo "✅ All tests passed!"
    exit 0
fi