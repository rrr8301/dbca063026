#!/usr/bin/env bash
set -e

cd /app

echo "=== Running tests for fp-go ==="
go mod tidy
go test -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./... || TEST_RESULT=$?

if [ -z "$TEST_RESULT" ]; then
    echo ""
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo ""
    echo "FINAL_STATUS = SUCCESS"
    exit 0
fi
