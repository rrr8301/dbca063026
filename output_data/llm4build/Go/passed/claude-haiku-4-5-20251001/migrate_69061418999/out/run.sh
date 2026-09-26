#!/bin/bash

set -e

# Create coverage directory
mkdir -p /tmp/coverage

# Run tests with coverage from workspace root
make test COVERAGE_DIR=/tmp/coverage

echo "Tests completed successfully"