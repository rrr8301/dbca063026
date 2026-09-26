#!/usr/bin/env bash
set -e

cd /app

echo "Building golangci-lint..."
go build -o golangci-lint ./cmd/golangci-lint

echo "Running golangci-lint on itself..."
./golangci-lint run -v

echo "Running unit tests..."
go test -v -parallel 2 ./...

echo "FINAL_STATUS = SUCCESS"
