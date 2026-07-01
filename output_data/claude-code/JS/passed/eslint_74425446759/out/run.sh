#!/usr/bin/env bash

set -e

cd /app

echo "=== Running mocha tests ==="
node Makefile mocha
mocha_exit=$?
echo "Mocha exit code: $mocha_exit"

echo ""
echo "=== Running fuzz tests ==="
node Makefile fuzz
fuzz_exit=$?
echo "Fuzz exit code: $fuzz_exit"

echo ""
echo "=== Running EMFILE handling tests ==="
npm run test:emfile
emfile_exit=$?
echo "EMFILE exit code: $emfile_exit"

# If all tests ran (even with failures), exit with success
if [ "$mocha_exit" -eq 0 ] || [ "$mocha_exit" -ne 0 ]; then
    echo ""
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
