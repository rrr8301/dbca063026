#!/bin/bash
set -e

# Navigate to workspace
cd /workspace

# Display Go version for verification
echo "Go version:"
go version

# Run integration tests with coverage
echo "Running integration tests with coverage..."
make test-integration-cov

echo "Integration tests completed successfully!"