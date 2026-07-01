#!/bin/bash

set -e

# Track test failures but continue execution
TEST_FAILED=0

echo "=== Running TypeScript Tests ==="
npm run test -- --no-lint --bundle=true || TEST_FAILED=1

# On test failure, run baseline acceptance and check diff
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Tests failed, checking baseline diff ==="
    npx hereby baseline-accept || true
    git add tests/baselines/reference || true
    git diff --staged --exit-code || true
fi

# Exit with appropriate code
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Test suite failed ==="
    exit 1
fi

echo "=== All tests passed ==="
exit 0