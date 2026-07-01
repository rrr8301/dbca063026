#!/usr/bin/env bash

set -e

echo "=== Running gofmt ==="
gofmt -d -e . 2>&1 | tee outfile && test -z "$(cat outfile)" && rm outfile

echo "=== Running go vet ==="
go vet ./...
cd _examples && go vet ./... && cd ..

echo "=== Running go test ==="
go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...
cd _examples && go test -v -race ./... && cd ..

echo "=== Running godog ==="
go install ./cmd/godog
godog -f progress --strict

echo ""
echo "FINAL_STATUS = SUCCESS"
