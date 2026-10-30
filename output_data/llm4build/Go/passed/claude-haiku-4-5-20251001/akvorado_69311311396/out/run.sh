#!/bin/bash

set -e

# Enable error handling: continue on test failures but track exit code
TEST_FAILED=0

echo "=== Go Environment Setup ==="
export GOCACHE=$(go env GOCACHE)
export GOMODCACHE=$(go env GOMODCACHE)
echo "GOCACHE: $GOCACHE"
echo "GOMODCACHE: $GOMODCACHE"

echo ""
echo "=== Go Version ==="
go version

echo ""
echo "=== Node Version ==="
node --version
npm --version
pnpm --version

echo ""
echo "=== Validating go.mod ==="
if go mod edit -json | jq -r .Go | grep -vPx '1.\d+' > /dev/null; then
    echo "ERROR: Incorrect go directive in go.mod: use only 'minor.major'."
    exit 1
fi
echo "✓ go.mod validation passed"

echo ""
echo "=== Installing Go dependencies ==="
go mod download
go mod verify

echo ""
echo "=== Installing Node dependencies ==="
cd console/frontend
pnpm install
cd ../../

echo ""
echo "=== Building project ==="
make
if [ ! -f ./bin/akvorado ]; then
    echo "ERROR: Build failed - akvorado binary not found"
    exit 1
fi
./bin/akvorado version

echo ""
echo "=== Checking IANA files ==="
if [ ! -f orchestrator/clickhouse/data/udp.csv ] || [ ! -f orchestrator/clickhouse/data/tcp.csv ]; then
    echo "IANA files not found, they will be generated during tests if needed"
fi

echo ""
echo "=== Running Go tests ==="
if ! make test-go; then
    TEST_FAILED=1
    echo "⚠ Some tests failed"
fi

echo ""
echo "=== Test Summary ==="
if [ $TEST_FAILED -eq 0 ]; then
    echo "✓ All tests passed"
    exit 0
else
    echo "✗ Some tests failed"
    exit 1
fi