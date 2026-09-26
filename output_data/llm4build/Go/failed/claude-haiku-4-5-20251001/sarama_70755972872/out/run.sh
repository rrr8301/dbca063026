#!/bin/bash

set -e

# Enable error handling - continue on test failures but track them
TEST_FAILED=0

echo "=== Go Version ==="
go version

echo "=== Environment Setup ==="
export PATH="/usr/local/go/bin:${PATH}"
export GOPATH="/root/go"
export GOFLAGS="-trimpath"
export DEBUG="true"
export TPARSE_VERSION="v0.18.0"

echo "=== Installing Go Dependencies ==="
go mod download
go mod verify

echo "=== Running Unit Tests ==="
if make test; then
    echo "Unit tests passed"
else
    echo "Unit tests failed"
    TEST_FAILED=1
fi

echo "=== Reporting Test Results ==="
if [ -f "_test/unittests.json" ]; then
    echo "Installing tparse..."
    go run github.com/mfridman/tparse@${TPARSE_VERSION} -all -format markdown -file _test/unittests.json | tee test_results.md || true
else
    echo "Warning: _test/unittests.json not found"
fi

echo "=== Reporting Per Function Code Coverage ==="
if [ -f "profile.out" ]; then
    {
        echo "## Per-Function Code Coverage"
        echo ""
        echo "|Filename|Function|Coverage|"
        echo "|--------|--------|--------|"
        go tool cover -func=profile.out | sed -E -e 's/[[:space:]]+/|/g' -e 's/$/|/g' -e 's/^/|/g'
    } | tee coverage_report.md || true
else
    echo "Warning: profile.out not found"
fi

echo "=== Test Execution Complete ==="

# Exit with failure if tests failed
if [ $TEST_FAILED -eq 1 ]; then
    exit 1
fi

exit 0