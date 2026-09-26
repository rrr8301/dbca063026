#!/usr/bin/env bash
set -e

cd /app

# Run the exact test commands from the workflow
go mod tidy
go test -race -coverprofile=coverage.txt -covermode=atomic -coverpkg=./... ./...

echo "FINAL_STATUS = SUCCESS"
