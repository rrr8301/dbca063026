#!/bin/bash

# Set Go environment
export PATH="/usr/local/go/bin:${PATH}"

# Clone the repository
git clone https://github.com/rook/rook.git /app
cd /app

# Install project dependencies
# Assuming dependencies are managed via Go modules
go mod download

# Run unit tests
export ROOK_UNIT_JQ_PATH="$(which jq)"
unset AZURE_EXTENSION_DIR
GOPATH=$(go env GOPATH) make -j $(nproc) test | tee output.txt

# Check for specific output in test results
if grep "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt; then
    echo "jq not found, fail the test"
    exit 1
fi