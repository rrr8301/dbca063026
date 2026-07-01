#!/bin/bash

set -eo pipefail

# Activate environment and verify Go installation
echo "=== Verifying Go installation ==="
go version
which go

# Verify jq installation
echo "=== Verifying jq installation ==="
which jq
jq --version

# Set required environment variables
export ROOK_UNIT_JQ_PATH="$(which jq)"
unset AZURE_EXTENSION_DIR

# Get GOPATH
GOPATH=$(go env GOPATH)
export GOPATH

echo "=== Environment Setup ==="
echo "GOPATH: $GOPATH"
echo "ROOK_UNIT_JQ_PATH: $ROOK_UNIT_JQ_PATH"

# Run unit tests with parallel execution
echo "=== Running Unit Tests ==="
make -j $(nproc) test | tee output.txt
TEST_EXIT_CODE=$?

# Check if mds liveness probe script ran successfully
echo "=== Checking MDS Liveness Probe Script ==="
if grep -q "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt; then
    echo "ERROR: jq not found during test execution"
    exit 1
fi

# Exit with test result code
if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "ERROR: Unit tests failed with exit code $TEST_EXIT_CODE"
    exit $TEST_EXIT_CODE
fi

echo "=== All Tests Passed ==="
exit 0