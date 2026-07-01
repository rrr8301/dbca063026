#!/bin/bash

set -e

# Set environment variables for tests
export GOTRACEBACK=single
export TEST_DOCKER=0
export TEST_FUSE=0
export TEST_VERBOSE=1
export GIT_PAGER=cat
export IPFS_CHECK_RCMGR_DEFAULTS=1

# Verify Go installation
go version

# Install project dependencies
go mod download
go mod verify

# Run unit tests
echo "Running unit tests..."
make test_unit

# Validate test results: ensure no failures in JSON output
echo "Validating test results..."
if [[ $(jq -s -c 'map(select(.Action == "fail")) | .[]' test/unit/gotest.json) ]]; then
    echo "Test failures detected in gotest.json"
    exit 1
fi

echo "All unit tests passed!"