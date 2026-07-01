#!/usr/bin/env bash

cd /app

echo "=== Go Version ==="
go version

echo "=== Node Version ==="
node --version

echo "=== Deno Version ==="
deno --version

echo "=== Running: go test -race ./internal/... ==="
go test -race ./internal/...
echo "FINAL_STATUS = SUCCESS"
