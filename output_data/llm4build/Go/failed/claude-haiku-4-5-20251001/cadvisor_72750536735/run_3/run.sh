#!/bin/bash

set -ex

# Source the configuration file
source build/config/libipmctl.sh

# Configure git safe directory
git config --global safe.directory /workspace

# Build cAdvisor
env GOOS=linux GOARCH=amd64 GO_FLAGS='-tags=libipmctl,cgo -race' ./build/build.sh

# Compile test binaries
env GOOS=linux GOFLAGS='-tags=libipmctl,cgo -race' go test -c github.com/google/cadvisor/integration/tests/api
env GOOS=linux GOFLAGS='-tags=libipmctl,cgo -race' go test -c github.com/google/cadvisor/integration/tests/common
env GOOS=linux GOFLAGS='-tags=libipmctl,cgo -race' go test -c github.com/google/cadvisor/integration/tests/metrics

# Run integration tests
env GOOS=linux GOFLAGS='-tags=libipmctl,cgo -race' go test -v github.com/google/cadvisor/integration/tests/api
env GOOS=linux GOFLAGS='-tags=libipmctl,cgo -race' go test -v github.com/google/cadvisor/integration/tests/common
env GOOS=linux GOFLAGS='-tags=libipmctl,cgo -race' go test -v github.com/google/cadvisor/integration/tests/metrics

exit 0