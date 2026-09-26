#!/bin/bash

set -e

# Enable error handling: continue on test failures but report them
TEST_FAILED=0

echo "=== Node.js and npm versions ==="
node --version
npm --version

echo ""
echo "=== Installing project dependencies ==="
npm install

echo ""
echo "=== Running tests ==="
if npm test -- --no-parallel; then
    echo "Tests passed"
else
    TEST_FAILED=1
    echo "Tests failed"
fi

echo ""
echo "=== Test run complete ==="

exit $TEST_FAILED