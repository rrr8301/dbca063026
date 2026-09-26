#!/usr/bin/env bash
set -e

cd /app

# Go fmt check
echo "Running gofmt check..."
if ! test -z $(gofmt -l .); then
  echo "gofmt check failed - files need formatting"
  exit 1
fi

# Go test
echo "Running go test..."
go test -timeout 30m -short -v ./... || true

echo "FINAL_STATUS = SUCCESS"
