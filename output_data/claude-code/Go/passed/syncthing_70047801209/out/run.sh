#!/usr/bin/env bash
set -e

cd /app

echo "=== Go Version ==="
go version

echo ""
echo "=== Build ==="
go run build.go

echo ""
echo "=== Test ==="
if go run build.go test | go-test-json-to-loki; then
    echo "FINAL_STATUS = SUCCESS"
    exit 0
else
    echo "FINAL_STATUS = FAIL"
    exit 1
fi
