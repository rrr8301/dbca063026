#!/bin/bash

set -e

cd /workspace

echo "=== Node.js and npm versions ==="
node --version
npm --version

echo "=== Installing dependencies via npm ci ==="
npm ci

echo "=== Running tests ==="
# Set BUNDLE environment variable (default to true if not set)
BUNDLE=${BUNDLE:-true}
npm run test -- --no-lint --bundle="$BUNDLE" || TEST_FAILED=1

echo "=== Checking for baseline diff on failure ==="
if [ "${TEST_FAILED}" = "1" ]; then
    echo "Tests failed. Attempting to accept baseline and check diff..."
    npx hereby baseline-accept || true
    git add tests/baselines/reference || true
    git diff --staged --exit-code || true
    exit 1
fi

echo "=== All tests passed ==="
exit 0