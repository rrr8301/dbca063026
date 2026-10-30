#!/bin/bash

set -e

# Navigate to the migrate directory where Makefile is located
cd /workspace/migrate

# Create coverage directory
mkdir -p /tmp/coverage

# Run tests with coverage
make test COVERAGE_DIR=/tmp/coverage

echo "Tests completed successfully"