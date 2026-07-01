#!/bin/bash
set -e

# Ensure we're in the workspace directory for all operations
cd /workspace

# Run verify-generate which includes go generate
# Run from the workspace root where relative paths are correct
GOWORK=off make verify-generate

# Run lint
GOWORK=off make lint

# Run build
GOWORK=off make build

# Run test
GOWORK=off make test