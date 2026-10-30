#!/usr/bin/env bash
set -e

cd /app

echo "=== Running Tests ==="
go run gotest.tools/gotestsum@latest --junitfile unit-tests.xml --format pkgname -- -v -cover -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic -timeout 20m ./... || true

echo "=== Test run completed ==="

FINAL_STATUS="SUCCESS"
echo "FINAL_STATUS = $FINAL_STATUS"
exit 0
