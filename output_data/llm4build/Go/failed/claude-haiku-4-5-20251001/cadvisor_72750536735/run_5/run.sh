#!/bin/bash

set -ex

# Source the configuration file
source build/config/libipmctl.sh

# Configure git safe directory
git config --global safe.directory /workspace

# Build cAdvisor
export GOOS=linux
export GOARCH=amd64
./build/build.sh

# Compile test binaries
export GOOS=linux
go test -c github.com/google/cadvisor/integration/tests/api
go test -c github.com/google/cadvisor/integration/tests/common
go test -c github.com/google/cadvisor/integration/tests/metrics

# Run integration tests
export GOOS=linux
go test -v github.com/google/cadvisor/integration/tests/api
go test -v github.com/google/cadvisor/integration/tests/common
go test -v github.com/google/cadvisor/integration/tests/metrics

exit 0