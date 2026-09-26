#!/bin/bash

# Set Go environment variables
export PATH="/usr/local/go/bin:${PATH}"

# Change to source directory
cd src

# Build all Go modules
./tool/go build ./...

# Build variant CLIs
./build_dist.sh --extra-small ./cmd/tailscaled
./build_dist.sh --box ./cmd/tailscaled
./build_dist.sh --extra-small --box ./cmd/tailscaled
rm -f tailscaled

# Build test wrapper
./tool/go build -o /tmp/testwrapper ./cmd/testwrapper

# Run tests
NOBASHDEBUG=true NOPWSHDEBUG=true PATH=$PWD/tool:$PATH /tmp/testwrapper ./...