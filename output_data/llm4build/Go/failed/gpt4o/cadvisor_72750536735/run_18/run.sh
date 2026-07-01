#!/bin/bash

set -ex

# Source environment variables
if [ -f build/config/libipmctl.sh ]; then
    source build/config/libipmctl.sh
else
    echo "Environment configuration file not found!"
    exit 1
fi

# Check if Go is installed and the correct version
go version

# Ensure the Go environment is set up for race detection
export CGO_ENABLED=1

# Run integration tests directly without Docker
# Ensure the correct usage of GO_FLAGS
make test-integration GO_FLAGS="${GO_FLAGS}" || {
    echo "Failed to run integration tests"
    exit 1
}