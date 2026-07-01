#!/usr/bin/env bash

set -euo pipefail

cd /app

# Run tests in a loop for 15 minutes (same as in the GitHub Actions workflow)
SECONDS=0
deadline=$((15 * 60))
iteration=1

while [ $SECONDS -lt $deadline ]; do
    echo "=== Iteration $iteration (elapsed ${SECONDS}s) ==="
    if ! cargo nextest run --workspace --lib --all-features --all-targets --profile ci; then
        echo "Tests failed during iteration $iteration"
        FINAL_STATUS="FAIL"
        exit 1
    fi
    iteration=$((iteration + 1))
done

completed=$((iteration - 1))
echo "Completed $completed iteration(s) in ${SECONDS}s without failures"
echo ""
echo "FINAL_STATUS = SUCCESS"
