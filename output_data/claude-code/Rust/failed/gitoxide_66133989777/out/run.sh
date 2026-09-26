#!/usr/bin/env bash
set -e

cd /app

export GIX_TEST_CREATE_ARCHIVES_EVEN_ON_CI=1

echo "=== Running cargo nextest ==="
cargo nextest run --workspace --no-fail-fast --exclude gix-error 2>&1 | tee test_output.log

if [ $? -eq 0 ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = FAIL"
fi
