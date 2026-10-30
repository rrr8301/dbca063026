#!/usr/bin/env bash
set -e

cd /app

echo "=== Go fmt check ==="
test -z $(gofmt -l .)

echo "=== Go test ==="
go test -timeout 30m -short -v ./...

echo "FINAL_STATUS = SUCCESS"
