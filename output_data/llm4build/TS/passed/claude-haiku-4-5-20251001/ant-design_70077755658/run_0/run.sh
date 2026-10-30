#!/bin/bash

set -e

# Activate environment (if needed)
export REACT=18
export SKIP_SEMANTIC=1

# Navigate to workspace
cd /workspace

# Ensure git is configured
git config --global --add safe.directory '*' || true

# Install project dependencies (if not already done)
npm install

# Run utoo setup (equivalent to setup-utoo action)
ut || echo "ut command not found, attempting to install utoo..."

# Run the test command with shard 1/2
# The command from the YAML: ut test -- --maxWorkers=2 --shard=1/2 --coverage
ut test -- --maxWorkers=2 --shard=1/2 --coverage

echo "Tests completed successfully!"