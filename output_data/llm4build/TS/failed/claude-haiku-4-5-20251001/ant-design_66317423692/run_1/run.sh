#!/bin/bash
set -e

# Print environment info
echo "Node version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Git version: $(git --version)"

# Set environment variables from matrix
export REACT=18
export SKIP_SEMANTIC=1

# Verify utoo is available
echo "Checking for utoo..."
if ! command -v ut &> /dev/null; then
    echo "Error: utoo (ut command) is not available"
    exit 1
fi

# Run utoo command
echo "Running ut command..."
ut

# Run tests with coverage and shard configuration
echo "Running tests with coverage..."
ut test -- --maxWorkers=2 --shard=2/2 --coverage

echo "Tests completed successfully!"