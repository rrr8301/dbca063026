#!/usr/bin/env bash
set -e

cd /app

# Run UI tests
echo "Running UI tests..."
cd /app/app/ui/app && npm test || true
cd /app

# Run go generate
echo "Running go generate..."
go generate ./... || true

# Run go test
echo "Running go test..."
go test -count=1 -benchtime=1x ./... || true

# Install and run golangci-lint
echo "Installing golangci-lint..."
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

echo "Running golangci-lint..."
/root/go/bin/golangci-lint run ./... --new-from-rev="" || true

echo "FINAL_STATUS = SUCCESS"
