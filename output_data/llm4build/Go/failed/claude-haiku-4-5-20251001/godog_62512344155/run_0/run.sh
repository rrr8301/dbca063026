#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

echo "=== Running gofmt check ==="
gofmt -d -e . 2>&1 | tee outfile && test -z "$(cat outfile)" && rm outfile

echo "=== Running go vet (main) ==="
go vet ./...

echo "=== Running go vet (_examples) ==="
cd _examples && go vet ./... && cd ..

echo "=== Running go test (main) ==="
go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

echo "=== Running go test (_examples) ==="
cd _examples && go test -v -race ./... && cd ..

echo "=== Installing godog ==="
go install ./cmd/godog

echo "=== Running godog ==="
godog -f progress --strict

echo "=== All tests completed successfully ==="