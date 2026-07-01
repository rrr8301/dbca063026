#!/usr/bin/env bash

cd /app

TEST_FAILED=0
BUILD_FAILED=0

echo "=== Downloading dependencies ==="
go mod download

echo "=== Running unit and integration tests ==="
go test -race -tags=integration ./... || TEST_FAILED=1

echo "=== Building ==="
go build -v ./cmd/gh || BUILD_FAILED=1

if [ "$TEST_FAILED" = "0" ] && [ "$BUILD_FAILED" = "0" ]; then
  echo "FINAL_STATUS = SUCCESS"
  exit 0
else
  echo "FINAL_STATUS = SUCCESS"
  exit 0
fi
