#!/bin/bash
set -e

# Verify Go installation
go version

# Create coverage directory
mkdir -p /tmp/coverage

# Run tests with coverage (from workspace root where go.mod and Makefile are located)
make test COVERAGE_DIR=/tmp/coverage

echo "Tests completed successfully"