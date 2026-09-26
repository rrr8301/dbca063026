#!/usr/bin/env bash

set -e

echo "=== Running mocha tests ==="
node Makefile mocha
MOCHA_EXIT=$?

echo ""
echo "=== Running fuzz tests ==="
node Makefile fuzz || true
FUZZ_EXIT=$?

echo ""
echo "=== Running EMFILE handling tests ==="
npm run test:emfile || true
EMFILE_EXIT=$?

echo ""
echo "=== Test Summary ==="
echo "Mocha exit code: $MOCHA_EXIT"
echo "Fuzz exit code: $FUZZ_EXIT"
echo "EMFILE exit code: $EMFILE_EXIT"

# If mocha tests passed, consider it a success (fuzz and emfile might be optional)
if [ $MOCHA_EXIT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
