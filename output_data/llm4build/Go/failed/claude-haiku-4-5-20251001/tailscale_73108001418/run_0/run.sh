#!/bin/bash
set -e

# Clone repository into src/ directory
if [ ! -d "src" ]; then
    git clone https://github.com/tailscale/tailscale.git src
fi

cd src

# Set environment variables
export GOMODCACHE="/workspace/gomodcache"
export CMD_GO_USE_GIT_HASH="true"
export GOARCH="amd64"
export NOBASHDEBUG="true"
export NOPWSHDEBUG="true"

# Ensure gomodcache directory exists
mkdir -p "$GOMODCACHE"

# Build all
echo "=== Building all packages ==="
./tool/go build ./...

# Build variant CLIs
echo "=== Building variant CLIs ==="
./build_dist.sh --extra-small ./cmd/tailscaled
./build_dist.sh --box ./cmd/tailscaled
./build_dist.sh --extra-small --box ./cmd/tailscaled
rm -f tailscaled

# Build test wrapper
echo "=== Building test wrapper ==="
./tool/go build -o /tmp/testwrapper ./cmd/testwrapper

# Run tests
echo "=== Running tests ==="
export PATH="$PWD/tool:$PATH"
/tmp/testwrapper ./...

echo "=== All tests completed ==="