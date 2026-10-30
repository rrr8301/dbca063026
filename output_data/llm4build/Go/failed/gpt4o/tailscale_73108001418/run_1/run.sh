#!/bin/bash

# Set Go environment variables
export PATH="/usr/local/go/bin:${PATH}"

# Change to source directory
cd /app/src || exit 1

# Build all Go modules
/app/tool/go build ./...

# Build variant CLIs
/app/build_dist.sh --extra-small ./cmd/tailscaled
/app/build_dist.sh --box ./cmd/tailscaled
/app/build_dist.sh --extra-small --box ./cmd/tailscaled
rm -f tailscaled

# Build test wrapper
/app/tool/go build -o /tmp/testwrapper ./cmd/testwrapper

# Run tests
NOBASHDEBUG=true NOPWSHDEBUG=true PATH=$PWD/tool:$PATH /tmp/testwrapper ./...