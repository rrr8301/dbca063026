#!/bin/bash

set -e

# Enable error handling but continue on test failures
TEST_FAILED=0

echo "=== Go Version ==="
go version

echo "=== Running Unit Tests ==="
if ! go run gotest.tools/gotestsum@latest --junitfile unit-tests.xml --format pkgname -- -v -cover -coverpkg=./... -coverprofile=coverage.txt -covermode=atomic -timeout 20m ./...; then
    echo "Unit tests failed, but continuing..."
    TEST_FAILED=1
fi

echo "=== Running act CLI test (with Docker support) ==="
if ! go run main.go -P ubuntu-latest=node:16-buster-slim -C ./pkg/runner/testdata/ -W ./basic/push.yml; then
    echo "Act CLI test with Docker support failed, but continuing..."
    TEST_FAILED=1
fi

echo "=== Running act CLI test (without Docker support) ==="
if ! go run -tags WITHOUT_DOCKER main.go -P ubuntu-latest=-self-hosted -C ./pkg/runner/testdata/ -W ./local-action-js/push.yml; then
    echo "Act CLI test without Docker support failed, but continuing..."
    TEST_FAILED=1
fi

echo "=== Test Summary ==="
if [ -f unit-tests.xml ]; then
    echo "JUnit test report generated: unit-tests.xml"
    cat unit-tests.xml
else
    echo "No JUnit test report found"
fi

echo "=== Coverage Report ==="
if [ -f coverage.txt ]; then
    echo "Coverage report generated: coverage.txt"
    head -20 coverage.txt
else
    echo "No coverage report found"
fi

# Exit with failure if any tests failed
if [ $TEST_FAILED -eq 1 ]; then
    echo "=== Some tests failed ==="
    exit 1
fi

echo "=== All tests passed ==="
exit 0