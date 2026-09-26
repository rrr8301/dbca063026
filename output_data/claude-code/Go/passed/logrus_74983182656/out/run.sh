#!/usr/bin/env bash
set -e

cd /app

echo "Running tests with go test -race -v ./..."
CGO_ENABLED=1 go test -race -v ./...

echo "FINAL_STATUS = SUCCESS"
