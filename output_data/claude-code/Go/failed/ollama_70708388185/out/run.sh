#!/usr/bin/env bash
set -e

cd /app

echo "Running go generate..."
go generate ./...

echo "Running go test..."
go test -count=1 -benchtime=1x ./... || {
  echo "FINAL_STATUS = FAIL"
  exit 1
}

echo "Running golangci-lint..."
golangci-lint run ./... || {
  echo "FINAL_STATUS = FAIL"
  exit 1
}

echo "FINAL_STATUS = SUCCESS"
