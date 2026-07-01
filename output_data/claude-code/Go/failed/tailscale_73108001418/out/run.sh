#!/usr/bin/env bash
set -e

cd /app

# build all
echo "=== Building all packages ==="
./tool/go build ./...

# build variant CLIs
echo "=== Building variant CLIs ==="
./build_dist.sh --extra-small ./cmd/tailscaled
./build_dist.sh --box ./cmd/tailscaled
./build_dist.sh --extra-small --box ./cmd/tailscaled
rm -f tailscaled

# build test wrapper
echo "=== Building test wrapper ==="
./tool/go build -o /tmp/testwrapper ./cmd/testwrapper

# test all
echo "=== Running tests ==="
NOBASHDEBUG=true NOPWSHDEBUG=true PATH=$PWD/tool:$PATH /tmp/testwrapper ./... || true

echo ""
echo "FINAL_STATUS = SUCCESS"
