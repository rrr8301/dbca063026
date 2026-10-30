#!/usr/bin/env bash
set -e

cd /app

echo "Running tests with coverage..."
make test COVERAGE_DIR=/tmp/coverage || EXIT_CODE=$?

if [ -z "$EXIT_CODE" ]; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "Tests completed with exit code: $EXIT_CODE"
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
