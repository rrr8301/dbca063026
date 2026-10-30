#!/bin/bash

set -e

# Print Go version for debugging
echo "Go version:"
go version

# Change to workspace
cd /workspace

# Download dependencies
echo "Downloading Go dependencies..."
go mod download

# Run gofmt check
echo "Running gofmt..."
gofmt -d -e . 2>&1 | tee outfile && test -z "$(cat outfile)" && rm outfile || (rm outfile && exit 1)

# Run go vet on main package
echo "Running go vet on main package..."
go vet ./...

# Run go vet on examples
echo "Running go vet on examples..."
cd _examples && go vet ./... && cd ..

# Run go test on main package with coverage
echo "Running go test on main package..."
go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

# Run go test on examples
echo "Running go test on examples..."
cd _examples && go test -v -race ./... && cd ..

# Install and run godog
echo "Installing godog..."
go install ./cmd/godog

echo "Running godog..."
godog -f progress --strict

echo "All tests completed successfully!"