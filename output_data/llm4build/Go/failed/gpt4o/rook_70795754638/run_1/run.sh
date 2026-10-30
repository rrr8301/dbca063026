#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Install Go dependencies
go mod download

# Run unit tests
export ROOK_UNIT_JQ_PATH="$(which jq)"
unset AZURE_EXTENSION_DIR
GOPATH=$(go env GOPATH) make -j $(nproc) test | tee output.txt

# Check for specific test output
if grep "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt; then
    echo "jq not found, fail the test"
    exit 1
fi