#!/bin/bash
set -e

# Set environment variables for the build
export CGO_ENABLED=0
export GOARCH=386
export GOLANGCILINT_VERSION=2.11.3

# Change to workspace directory
cd /workspace

# Run tests
make test