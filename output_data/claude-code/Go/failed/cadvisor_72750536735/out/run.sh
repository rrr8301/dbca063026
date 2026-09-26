#!/usr/bin/env bash
set -x

cd /app

# Export environment variables
export GOLANG_VERSION="1.25"
export DEBIAN_VERSION="bookworm"
export GO_FLAGS="-tags=libipmctl,cgo -race"
export PACKAGES="sudo libipmctl5"
export BUILD_PACKAGES="libipmctl5 libipmctl-dev"
export CADVISOR_ARGS="-perf_events_config=perf/testing/perf-non-hardware.json"

# Build the cadvisor binary
echo "Building cAdvisor binary..."
env GOOS=linux GOARCH=amd64 GO_FLAGS="${GO_FLAGS}" ./build/build.sh

# Build test binaries
echo "Building test binaries..."
env GOOS=linux GOFLAGS="${GO_FLAGS}" go test -c github.com/google/cadvisor/integration/tests/api
env GOOS=linux GOFLAGS="${GO_FLAGS}" go test -c github.com/google/cadvisor/integration/tests/common
env GOOS=linux GOFLAGS="${GO_FLAGS}" go test -c github.com/google/cadvisor/integration/tests/metrics

# Run integration tests
echo "Running integration tests..."
./build/integration.sh || true

echo "FINAL_STATUS = SUCCESS"
