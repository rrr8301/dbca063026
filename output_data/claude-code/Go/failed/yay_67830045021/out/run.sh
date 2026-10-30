#!/usr/bin/env bash
set -e

cd /app

echo "=== Running Lint ==="
/app/bin/golangci-lint run -v ./...

echo "=== Running Build and Tests ==="
make test

echo "FINAL_STATUS = SUCCESS"
