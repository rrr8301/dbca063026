#!/bin/bash
set -e

# Ensure we're in the workspace directory for all operations
cd /workspace

# Run verify-generate which includes go generate
# The Makefile target should handle the correct working directory
GOWORK=off make verify-generate

# Run lint
GOWORK=off make lint

# Run build
GOWORK=off make build

# Run test
GOWORK=off make test