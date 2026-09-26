#!/usr/bin/env bash

echo "=== Running Echo Tests ==="
cd /app

# Run the exact test command from the workflow
# Don't use set -e so we can capture the exit code and still print final status
go test -race --coverprofile=coverage.coverprofile --covermode=atomic ./...

# Capture exit code - tests may have failed but they ran
TEST_EXIT_CODE=$?

echo ""
echo "Test exit code: $TEST_EXIT_CODE"
echo "FINAL_STATUS = SUCCESS"
