#!/bin/bash

set -eo pipefail

# Set Go environment
export PATH="/usr/local/go/bin:$PATH"
export GOPATH="$(go env GOPATH)"

# Set jq path for Rook unit tests
export ROOK_UNIT_JQ_PATH="$(which jq)"

# Unset Azure extension directory
unset AZURE_EXTENSION_DIR

# Print diagnostic info
echo "Go version: $(go version)"
echo "jq version: $(jq --version)"
echo "ROOK_UNIT_JQ_PATH: $ROOK_UNIT_JQ_PATH"
echo "GOPATH: $GOPATH"
echo "Number of processors: $(nproc)"

# Run unit tests with parallel execution
echo "Running unit tests..."
make -j $(nproc) test | tee output.txt
TEST_EXIT_CODE=$?

# Check mds liveness probe script ran successfully
echo ""
echo "Checking mds liveness probe script..."
if grep -q "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt; then
    echo "ERROR: jq not found or not properly configured"
    exit 1
fi

# Exit with test result code
exit $TEST_EXIT_CODE