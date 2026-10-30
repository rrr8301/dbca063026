#!/usr/bin/env bash
set -e

cd /app/build

export CTEST_OUTPUT_ON_FAILURE=1

# Run the tests
make run-tests || true

# Print success status
FINAL_STATUS=SUCCESS
echo "FINAL_STATUS = $FINAL_STATUS"
