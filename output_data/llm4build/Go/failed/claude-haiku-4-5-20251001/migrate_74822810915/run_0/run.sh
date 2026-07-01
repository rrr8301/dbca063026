#!/bin/bash
set -e

# Navigate to the migrate directory (where go.mod and Makefile are located)
cd /workspace/migrate

# Verify Go installation
go version

# Create coverage directory
mkdir -p /tmp/coverage

# Run tests with coverage
make test COVERAGE_DIR=/tmp/coverage

echo "Tests completed successfully"