#!/bin/bash

set -eo pipefail

# Enable debug output
set -x

# Clone the repository (assuming it's passed as an environment variable or argument)
# For local testing, assume the repo is already mounted or copied
if [ ! -d "/workspace/.git" ]; then
    echo "Repository not found. Assuming it will be mounted or copied."
fi

cd /workspace

# Verify Go installation
go version

# Verify jq installation
which jq
jq --version

# Set jq path for the test
export ROOK_UNIT_JQ_PATH="$(which jq)"

# Unset Azure extension directory (as per the workflow)
unset AZURE_EXTENSION_DIR

# Get GOPATH
GOPATH=$(go env GOPATH)

# Run unit tests with parallel execution
# Capture output to file and also display it
make -j $(nproc) test 2>&1 | tee output.txt
TEST_EXIT_CODE=${PIPESTATUS[0]}

# Check if mds liveness probe script ran successfully
if grep -q "skipping mds liveness probe script unit tests because jq binary location is not known" output.txt; then
    echo "ERROR: jq not found during test execution"
    exit 1
fi

# Exit with the test result code
exit $TEST_EXIT_CODE