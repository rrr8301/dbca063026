#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=== Loading environment variables from .github/env ==="
if [ -f ".github/env" ]; then
    set -a
    source .github/env
    set +a
    echo "Environment variables loaded:"
    cat .github/env
else
    echo "Warning: .github/env not found, using defaults"
    export GOLANG_VERSION=${GOLANG_VERSION:-1.22.0}
fi

# Ensure all scripts have execute permissions
chmod -R +x ./scripts/ || true

echo ""
echo "=== Go Version ==="
go version

echo ""
echo "=== Verifying Go modules ==="
go mod download
go mod verify

echo ""
echo "=== Testing source headers are present ==="
if ! make test-source-headers; then
    echo "ERROR: Source headers test failed"
    TEST_FAILED=1
fi

echo ""
echo "=== Checking if go modules need to be tidied ==="
if ! go mod tidy -diff; then
    echo "ERROR: Go modules are not tidy"
    TEST_FAILED=1
fi

echo ""
echo "=== Running unit tests with coverage ==="
if ! make test-coverage; then
    echo "ERROR: Unit tests failed"
    TEST_FAILED=1
fi

echo ""
echo "=== Building project ==="
if ! make build; then
    echo "ERROR: Build failed"
    TEST_FAILED=1
fi

echo ""
echo "=== Build and test summary ==="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All checks passed successfully"
    exit 0
else
    echo "✗ Some checks failed (see errors above)"
    exit 1
fi