#!/bin/bash

# Activate environment variables
source build/config/plain.sh

# Install project dependencies
if [[ "${BUILD_PACKAGES}" != "" ]]; then
    apt-get update
    apt-get install -y ${BUILD_PACKAGES}
fi

# Ensure golangci-lint is in PATH
export PATH=$(go env GOPATH)/bin:$PATH

# Update go.mod to use the correct Go version
sed -i 's/^go .*/go 1.20/' go.mod

# Run presubmit checks
make -e presubmit

# Enable cgo for race detection
export CGO_ENABLED=1

# Run tests
make test  # Ensure all tests run