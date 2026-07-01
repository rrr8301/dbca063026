#!/bin/bash
set -e

# Set environment variables from matrix
export REACT=18
export SKIP_SEMANTIC=1

# Ensure we're in the workspace
cd /workspace

# Install utoo (custom tool setup)
# The setup-utoo@v1 action typically installs utoo globally
# Assuming it's available via npm or needs to be installed from a specific source
npm install -g utoo || true

# Run ut command (initial setup)
ut

# Run dom test with exact parameters from YAML
ut test -- --maxWorkers=2 --shard=2/2 --coverage

echo "✅ All tests completed successfully!"