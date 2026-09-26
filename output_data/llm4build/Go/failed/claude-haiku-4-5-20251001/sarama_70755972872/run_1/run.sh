#!/bin/bash

set -e

# Enable debug mode if DEBUG is set
if [ "$DEBUG" = "true" ]; then
    set -x
fi

# Verify Go installation
echo "Go version:"
go version

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download

# Run unit tests
echo "Running unit tests..."
TEST_FAILED=0
make test || TEST_FAILED=1

# Report test results using tparse
echo "Reporting test results..."
if [ -f "_test/unittests.json" ]; then
    go run github.com/mfridman/tparse@${TPARSE_VERSION} -all -format markdown -file _test/unittests.json | tee test_report.md
else
    echo "Warning: _test/unittests.json not found"
fi

# Report per-function code coverage
echo "Reporting per-function code coverage..."
if [ -f "profile.out" ]; then
    {
        echo "## Per-Function Code Coverage"
        echo ""
        echo "|Filename|Function|Coverage|"
        echo "|--------|--------|--------|"
        go tool cover -func=profile.out | sed -E -e 's/[[:space:]]+/|/g' -e 's/$/|/g' -e 's/^/|/g'
    } | tee coverage_report.md
else
    echo "Warning: profile.out not found"
fi

# Exit with failure if tests failed
if [ "$TEST_FAILED" = "1" ]; then
    echo "Tests failed!"
    exit 1
fi

echo "All tests completed successfully!"