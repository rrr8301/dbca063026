#!/bin/bash

set -e

# Track test failures but continue execution
TEST_FAILED=0

echo "=== Installing Go dependencies ==="
go mod download
go mod verify

echo "=== Installing UI dependencies ==="
if [ -d "./app/ui/app" ]; then
    cd ./app/ui/app
    npm ci
    cd /workspace
else
    echo "UI directory not found, skipping UI dependencies installation"
fi

echo "=== Installing tscriptify ==="
go install github.com/tkrajina/typescriptify-golang-structs/tscriptify@latest

echo "=== Running UI tests ==="
if [ -d "./app/ui/app" ]; then
    cd ./app/ui/app
    if ! npm test; then
        echo "UI tests failed"
        TEST_FAILED=1
    fi
    cd /workspace
else
    echo "UI directory not found, skipping UI tests"
fi

echo "=== Running go generate ==="
if ! go generate ./...; then
    echo "go generate failed"
    TEST_FAILED=1
fi

echo "=== Running Go tests ==="
if ! go test -count=1 -benchtime=1x ./...; then
    echo "Go tests failed"
    TEST_FAILED=1
fi

echo "=== Running golangci-lint ==="
if ! /usr/local/go/bin/golangci-lint run --new-from-rev=HEAD~1 ./...; then
    echo "golangci-lint found issues (new issues only)"
    TEST_FAILED=1
fi

if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Some tests failed ==="
    exit 1
fi

echo "=== All tests passed ==="
exit 0