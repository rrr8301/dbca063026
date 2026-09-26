#!/bin/bash

set -e

echo "=========================================="
echo "Starting Bytebase Backend Tests"
echo "=========================================="

# Navigate to workspace
cd /workspace

# Export Go environment variables
export GOPATH=/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

echo ""
echo "=========================================="
echo "Go Version"
echo "=========================================="
go version

echo ""
echo "=========================================="
echo "Downloading Go Dependencies"
echo "=========================================="
go mod download
go mod verify

echo ""
echo "=========================================="
echo "Running Go Linting (golangci-lint)"
echo "=========================================="
if [ -f .golangci.yaml ]; then
    golangci-lint run ./... || echo "Linting warnings/errors detected (non-blocking)"
else
    echo "No .golangci.yaml found, skipping linting"
fi

echo ""
echo "=========================================="
echo "Building Backend"
echo "=========================================="
mkdir -p ./bytebase-build
go build -ldflags "-w -s" -p=16 -o ./bytebase-build/bytebase ./backend/bin/server/main.go || echo "Backend build completed with status: $?"

echo ""
echo "=========================================="
echo "Running Go Tests"
echo "=========================================="
go test -v -race -coverprofile=coverage.out ./... || TEST_FAILED=1

echo ""
echo "=========================================="
echo "Frontend Setup (pnpm)"
echo "=========================================="
if [ -f frontend/package.json ]; then
    cd frontend
    pnpm install --frozen-lockfile || echo "Frontend dependencies installation completed with status: $?"
    cd ..
else
    echo "No frontend/package.json found, skipping frontend setup"
fi

echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
if [ -f coverage.out ]; then
    echo "Coverage report generated: coverage.out"
    go tool cover -func=coverage.out | tail -1
fi

if [ "$TEST_FAILED" = "1" ]; then
    echo "Some tests failed, but test suite execution completed."
    exit 1
fi

echo ""
echo "=========================================="
echo "All Tests Completed Successfully"
echo "=========================================="
exit 0