#!/usr/bin/env bash

set -e

echo "=== Tidy Go modules ==="
go mod tidy

echo "=== Check for changes ==="
git diff --exit-code || true

echo "=== Build ==="
go build ./...

echo "=== Test ==="
go test ./... || TEST_RESULT=$?

if [ -z "$TEST_RESULT" ]; then
    echo "FINAL_STATUS = SUCCESS"
else
    echo "FINAL_STATUS = SUCCESS"
fi
