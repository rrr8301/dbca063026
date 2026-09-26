#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=== Installing dependencies ==="
pnpm install --frozen-lockfile

echo "=== Generating code ==="
pnpm buf generate --template buf.ts.gen.yaml

echo "=== Building composition, connect, and shared ==="
pnpm run --filter ./composition --filter ./connect --filter ./shared build

echo "=== Running tests with coverage ==="
if ! pnpm run --filter composition test:coverage; then
    TEST_FAILED=1
fi

echo "=== Running linter ==="
if ! pnpm run --filter composition lint; then
    TEST_FAILED=1
fi

echo "=== Test and lint execution completed ==="

# Exit with failure code if any test or lint step failed
if [ $TEST_FAILED -ne 0 ]; then
    exit 1
fi

exit 0