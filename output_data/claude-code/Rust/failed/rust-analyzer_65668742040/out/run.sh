#!/usr/bin/env bash
set -e

echo "=== Starting CI Job ==="

# Run codegen checks
echo "=== Running codegen checks ==="
cargo codegen --check
if [ $? -ne 0 ]; then
    echo "Codegen checks failed"
    echo "FINAL_STATUS = FAIL"
    exit 1
fi

# Run tests
echo "=== Running tests ==="
cargo nextest run --no-fail-fast --hide-progress-bar
TEST_RESULT=$?

# Run cargo-machete
echo "=== Running cargo-machete ==="
cargo machete
MACHETE_RESULT=$?

# Print final status
if [ $TEST_RESULT -eq 0 ] && [ $MACHETE_RESULT -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
